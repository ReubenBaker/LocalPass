//
//  NoteDetailView.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import SwiftUI

struct NoteDetailView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @EnvironmentObject private var notesViewModel: NotesViewModel
    @Binding var note: Note
    @State private var newTitle: String?
    @State private var newBody: String?
    @State private var newUpdatedDateTime: Date?
    @State private var showDeleteAlert: Bool = false
    @FocusState private var focusedTextField: GlobalHelperDataService.FocusedTextField?
    
    var body: some View {
        VStack {
            if editMode?.wrappedValue != .active {
                titleItem
                bodyItem
            } else {
                editTitleItem
                editBodyItem
            }
            
            VStack(alignment: .leading) {
                creationDateTimeItem
                updatedDateTimeItem
            }
            
            deleteItem
            Spacer()
            CloseButtonView()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(.ultraThinMaterial)
        .alert(isPresented: $showDeleteAlert) {
            notesViewModel.getDeleteAlert() {
                dismiss()
            }
        }
        .onChange(of: editMode?.wrappedValue) { mode in
            if mode != .active {
                if (newTitle != nil && newTitle != note.title) || (newBody != nil && newBody != note.body) {
                    let updatedNote = Note(
                        title: newTitle ?? note.title,
                        body: newBody ?? note.body,
                        creationDateTime: note.creationDateTime,
                        updatedDateTime: Date(),
                        starred: note.starred,
                        id: note.id
                    )
                    
                    newUpdatedDateTime = Date()
                    
                    notesViewModel.updateNote(id: note.id, note: updatedNote)
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase != .active && LocalPassApp.settings.lockVaultOnBackground {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismiss()
                }
            }
        }
    }
}

// Preview
struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var notesViewModel = NotesViewModel()
        @State var note = Note(title: "default", body: "default")
        
        NoteDetailView(note: $note)
            .environmentObject(notesViewModel)
    }
}

// Views
extension NoteDetailView {
    private var titleItem: some View {
        ZStack {
            Text(newTitle ?? note.title)
                .modifier(TitleTextStyle())
            
            HStack {
                EditButton()
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var editTitleItem: some View {
        ZStack {
            TextField("\(newTitle ?? note.title)", text: Binding(
                get: { newTitle ?? "" },
                set: { newTitle = $0 }
            ))
                .modifier(TitleTextStyle())
                .tint(.primary)
                .multilineTextAlignment(.center)
                .focused($focusedTextField, equals: .title)
                .onTapGesture {
                    DispatchQueue.main.async {
                        focusedTextField = .title
                    }
                }
                .onAppear {
                    if newTitle == nil {
                        newTitle = note.title
                    }
                }
            
            HStack {
                EditButton()
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var bodyItem: some View {
        Text(newBody ?? note.body)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .font(.headline)
            .padding()
            .padding(4)
    }
    
    private var editBodyItem: some View {
        TextEditor(text: Binding(
            get: { newBody ?? "" },
            set: { newBody = $0 }
        ))
            .modifier(TextEditorStyle())
            .focused($focusedTextField, equals: .body)
            .onTapGesture {
                DispatchQueue.main.async {
                    focusedTextField = .body
                }
            }
            .onAppear {
                if newBody == nil {
                    newBody = note.body
                }
            }
    }
    
    private var creationDateTimeItem: some View {
        ZStack {
            let createdText = Text("\(GlobalHelperDataService.dateFormatter.string(from: note.creationDateTime))")
            
            return Label("Time Created: \(createdText)", systemImage: "plus.circle")
        }
    }
    
    private var updatedDateTimeItem: some View {
        ZStack {
            var lastUpdatedText = Text("Never")

            if let lastUpdated = newUpdatedDateTime ?? note.updatedDateTime {
                lastUpdatedText = Text("\(GlobalHelperDataService.dateFormatter.string(from: lastUpdated))")
            }
            
            return Label("Last Updated: \(lastUpdatedText)", systemImage: "pencil.circle")
        }
    }
    
    private var deleteItem: some View {
        Button("Delete") {
            notesViewModel.noteToDelete = note
            showDeleteAlert.toggle()
        }
        .buttonStyle(ProminentButtonStyle(.red))
    }
}

//
//  NoteDetailView.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import SwiftUI

struct NoteDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var notesViewModel: NotesViewModel
    @EnvironmentObject private var copyPopupOverlayViewModel: CopyPopupOverlayViewModel
    @Binding var note: Note
    @State private var newTitle: String = ""
    @State private var newBody: String = ""
    @State private var showDeleteAlert: Bool = false
    @FocusState private var focusedTextField: GlobalHelperDataService.FocusedTextField?
    
    var body: some View {
        ScrollView {
            VStack {
                if editMode?.wrappedValue != .active {
                    titleItem
                    bodyItem
                } else {
                    editTitleItem
                    editBodyItem
                }
                
                creationDateTimeItem
                updatedDateTimeItem
                deleteItem
                CloseButtonView()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .background(.ultraThinMaterial)
        .alert(isPresented: $showDeleteAlert) {
            notesViewModel.getDeleteAlert()
        }
        .onChange(of: editMode?.wrappedValue) { mode in
            if mode != .active {           
                if newTitle != "" || newBody != "" {
                    let updatedNote = Note(
                        title: newTitle != "" ? newTitle : note.title,
                        body: newBody != "" ? newBody : note.body,
                        creationDateTime: note.creationDateTime,
                        updatedDateTime: Date(),
                        starred: note.starred,
                        id: note.id
                    )
                    
                    notesViewModel.updateNote(id: note.id, note: updatedNote)
                    
                    (newTitle, newBody) = ("", "")
                }
            }
        }
        .onDisappear {
            notesViewModel.updateNote(id: note.id, note: note)
        }
    }
}

// Preview
struct NoteDetailView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var notesViewModel = NotesViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @State var note = Note(title: "default", body: "default")
        
        NoteDetailView(note: $note)
            .environmentObject(mainViewModel)
            .environmentObject(notesViewModel)
            .environmentObject(copyPopupOverlayViewModel)
    }
}

// Views
extension NoteDetailView {
    private var titleItem: some View {
        ZStack {
            Text(note.title)
                .modifier(TitleTextStyle())
            
            HStack {
                EditButton()
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.top, copyPopupOverlayViewModel.showCopyPopupOverlay ? 30 : 0)
    }
    
    private var editTitleItem: some View {
        ZStack {
            TextField("\(note.title)", text: $newTitle)
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
                    newTitle = note.title
                }
            
            HStack {
                EditButton()
                Spacer()
            }
            .padding(.horizontal)
        }
    }
    
    private var bodyItem: some View {
        Text(note.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
            .lineLimit(20...20)
            .padding()
    }
    
    private var editBodyItem: some View {
        TextField("", text: $newBody, axis: .vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
            .padding()
            .padding(.top, 4)
            .tint(.primary)
            .lineLimit(20...20)
            .scrollContentBackground(.hidden)
            .focused($focusedTextField, equals: .body)
            .onTapGesture {
                DispatchQueue.main.async {
                    focusedTextField = .body
                }
            }
            .onAppear {
                newBody = note.body
            }
    }
    
    private var creationDateTimeItem: some View {
        ZStack {
            let createdText = Text("\(GlobalHelperDataService.dateFormatter.string(from: note.creationDateTime))")
            
            return Text("Time Created: \(createdText)")
        }
    }
    
    private var updatedDateTimeItem: some View {
        ZStack {
            var lastUpdatedText = Text("Never")

            if let lastUpdated = note.updatedDateTime {
                lastUpdatedText = Text("\(GlobalHelperDataService.dateFormatter.string(from: lastUpdated))")
            }
            
            return Text("Last Updated: \(lastUpdatedText)")
        }
    }
    
    private var deleteItem: some View {
        Button("Delete") {
            notesViewModel.noteToDelete = note
            showDeleteAlert.toggle()
        }
        .buttonStyle(DeleteButtonStyle())
    }
}

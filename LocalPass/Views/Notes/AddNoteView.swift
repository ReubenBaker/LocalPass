//
//  AddNoteView.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import SwiftUI

struct AddNoteView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notesViewModel: NotesViewModel
    @State private var newTitle: String = ""
    @State private var newBody: String = ""
    @State private var noteSuccess: Bool = false
    @FocusState private var focusedTextField: GlobalHelperDataService.FocusedTextField?
    
    var body: some View {
        VStack {
            titleItem
            bodyItem
            addItem
            Spacer()
            CloseButtonView()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .background(.ultraThinMaterial)
        .onChange(of: scenePhase) { phase in
            if phase != .active && LocalPassApp.settings.lockVaultOnBackground {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismiss()
                }
            }
        }
        .onChange(of: noteSuccess) { _ in
            dismiss()
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var notesViewModel = NotesViewModel()
        
        AddNoteView()
            .environmentObject(notesViewModel)
    }
}

// Views
extension AddNoteView {
    private var titleItem: some View {
        TextField("Title...", text: $newTitle)
            .modifier(TitleTextStyle())
            .tint(.primary)
            .multilineTextAlignment(.center)
            .focused($focusedTextField, equals: .title)
            .onTapGesture {
                DispatchQueue.main.async {
                    focusedTextField = .title
                }
            }
    }
    
    private var bodyItem: some View {
        TextEditor(text: $newBody)
            .modifier(TextEditorStyle())
            .focused($focusedTextField, equals: .body)
            .onTapGesture {
                DispatchQueue.main.async {
                    focusedTextField = .body
                }
            }
            .overlay(alignment: .topLeading) {
                if newBody == "" {
                    Text("Note...")
                        .font(.headline)
                        .padding()
                        .padding(4)
                        .padding(.top, 4)
                        .opacity(0.25)
                }
            }
    }
    
    private var addItem: some View {
        Button {
            noteSuccess = notesViewModel.addNote(
                title: newTitle,
                body: newBody
            )
        } label: {
            Text("Add Note")
        }
        .buttonStyle(ProminentButtonStyle(.cyan))
    }
}

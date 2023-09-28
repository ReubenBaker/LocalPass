//
//  AddNoteView.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import SwiftUI

struct AddNoteView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notesViewModel: NotesViewModel
    @State private var newTitle: String = ""
    @State private var newBody: String = ""
    @State private var noteSuccess: Bool = false
    @State private var showNoteSuccessAlert: Bool = false
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
        .alert(isPresented: $showNoteSuccessAlert) {
            getNoteSuccessAlert(noteSuccess: noteSuccess)
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

// Functions
extension AddNoteView {
    private func getNoteSuccessAlert(noteSuccess: Bool) -> Alert {
        var title: Text = Text("")
        
        if noteSuccess {
            title = Text("Note successfully created!")
        } else {
            title = Text("Note could not be created!")
        }
        
        let dismissButton: Alert.Button = .default(noteSuccess ? Text("🥳") : Text("😢"), action: {
            if noteSuccess {
                dismiss()
            }
        })
        
        return Alert(
            title: title,
            message: nil,
            dismissButton: dismissButton
        )
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
            
            showNoteSuccessAlert.toggle()
        } label: {
            Text("Add Note")
        }
        .buttonStyle(ProminentButtonStyle(.cyan))
    }
}

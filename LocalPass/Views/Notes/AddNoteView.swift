//
//  AddNoteView.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import SwiftUI

struct AddNoteView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var notesViewModel: NotesViewModel
    @State private var newTitle: String = ""
    @State private var newBody: String = ""
    @State private var noteSuccess: Bool = false
    @State private var showNoteSuccessAlert: Bool = false
    @FocusState private var titleTextFieldFocused: Bool
    @FocusState private var bodyTextFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                titleItem
                bodyItem
                addItem
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .background(.ultraThinMaterial)
        .overlay(closeButton, alignment: .bottom)
        .overlay {
            PrivacyOverlayView()
        }
        .alert(isPresented: $showNoteSuccessAlert) {
            getNoteSuccessAlert(noteSuccess: noteSuccess)
        }
    }
}

struct AddNoteView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var notesViewModel = NotesViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        
        AddNoteView()
            .environmentObject(mainViewModel)
            .environmentObject(notesViewModel)
            .environmentObject(privacyOverlayViewModel)
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
        TextField("Enter title...", text: $newTitle)
            .font(.title)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.horizontal, 70)
            .tint(.primary)
            .multilineTextAlignment(.center)
            .focused($titleTextFieldFocused)
            .onTapGesture {
                DispatchQueue.main.async {
                    titleTextFieldFocused = true
                }
            }
    }
    
    private var bodyItem: some View {
        TextField("Note...", text: $newBody, axis: .vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
            .padding()
            .padding(.top, 4)
            .tint(.primary)
            .lineLimit(22...22)
            .scrollContentBackground(.hidden)
            .focused($bodyTextFieldFocused)
            .onTapGesture {
                DispatchQueue.main.async {
                    bodyTextFieldFocused = true
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
                .font(.headline)
                .padding()
                .foregroundColor(.primary)
                .frame(minWidth: 150)
                .background(.cyan)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
        }
    }
    
    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .padding()
                .foregroundColor(Color("AccentColor"))
                .background(.thickMaterial)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding()
        }
    }
}

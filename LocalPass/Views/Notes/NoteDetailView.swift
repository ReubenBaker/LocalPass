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
    @FocusState private var titleTextFieldFocused: Bool
    @FocusState private var bodyTextFieldFocused: Bool
    
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
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .background(.ultraThinMaterial)
        .overlay(closeButton, alignment: .bottom)
        .overlay(CopyPopupOverlayView(), alignment: .top)
        .overlay(PrivacyOverlayView())
        .alert(isPresented: $showDeleteAlert) {
            notesViewModel.getDeleteAlert()
        }
        .onChange(of: editMode?.wrappedValue) { editMode in
            if editMode == .inactive {
                if newTitle != "" {
                    let updatedNote = Note(title: newTitle, body: note.body, creationDateTime: note.creationDateTime, updatedDateTime: Date(), starred: note.starred)
                    
                    notesViewModel.updateNote(id: note.id, note: updatedNote)
                    
                    newTitle = ""
                }
                
                if newBody != "" {
                    let updatedNote = Note(title: note.title, body: newBody, creationDateTime: note.creationDateTime, updatedDateTime: Date(), starred: note.starred)
                    
                    notesViewModel.updateNote(id: note.id, note: updatedNote)
                    
                    newBody = ""
                }
            }
        }
        .onDisappear { // TEST!
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
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        @State var note = Note(title: "default", body: "default")
        
        NoteDetailView(note: $note)
            .environmentObject(mainViewModel)
            .environmentObject(notesViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(privacyOverlayViewModel)
    }
}

// Views
extension NoteDetailView {
    private var titleItem: some View {
        ZStack {
            Text(note.title)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(2)
                .padding(.horizontal, 70)
            
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
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(2)
                .padding(.horizontal, 70)
                .tint(.primary)
                .focused($titleTextFieldFocused)
                .onTapGesture {
                    DispatchQueue.main.async {
                        titleTextFieldFocused = true
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
        Text(note.body)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.headline)
            .padding()
    }
    
    private var editBodyItem: some View {
        TextEditor(text: $newBody)
            .font(.headline)
            .padding()
            .tint(.primary)
            .focused($bodyTextFieldFocused)
            .onTapGesture {
                DispatchQueue.main.async {
                    bodyTextFieldFocused = true
                }
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

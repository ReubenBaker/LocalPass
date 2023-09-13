//
//  NoteListItemView.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import SwiftUI

struct NoteListItemView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var notesViewModel: NotesViewModel
    @EnvironmentObject private var copyPopupOverlayViewModel: CopyPopupOverlayViewModel
    @Binding var note: Note
    @State private var showNoteDetailViewSheet: Bool = false
    
    var body: some View {
        noteListItem
            .fullScreenCover(isPresented: $showNoteDetailViewSheet) {
                NoteDetailView(note: $note)
                    .overlay(PrivacyOverlayView())
            }
    }
}

// Preview
struct NoteListItemView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var notesViewModel = NotesViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @State var note = Note(title: "Test Title", body: "Test Body")
        
        NoteListItemView(note: $note)
            .environmentObject(mainViewModel)
            .environmentObject(notesViewModel)
            .environmentObject(copyPopupOverlayViewModel)
    }
}

// Views
extension NoteListItemView {
    private var noteListItem: some View {
        Button {
            showNoteDetailViewSheet.toggle()
        } label: {
            HStack {
                Image(systemName: note.starred ? "star.fill" : "pencil.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("AccentColor"))
                
                Text(note.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    mainViewModel.copyToClipboard(text: note.body) // Keep?
                    copyPopupOverlayViewModel.displayCopyPopupOverlay()
                } label: {
                    Image(systemName: "doc.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .frame(height: mainViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
    }
}

//
//  NoteListItemView.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import SwiftUI

struct NoteListItemView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var copyPopupOverlayViewModel: CopyPopupOverlayViewModel
    @Binding var note: Note
    @State private var showNoteDetailViewSheet: Bool = false
    
    var body: some View {
        noteListItem
            .fullScreenCover(isPresented: $showNoteDetailViewSheet) {
                NoteDetailView(note: $note)
                    .overlay(PrivacyOverlayView())
                    .onChange(of: scenePhase) { phase in
                        withAnimation(.easeOut) {
                            if phase != .active {
                                if LocalPassApp.settings.lockVaultOnBackground {
                                    showNoteDetailViewSheet = false
                                }
                            }
                        }
                    }
            }
    }
}

// Preview
struct NoteListItemView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var notesViewModel = NotesViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @State var note = Note(title: "Test Title", body: "Test Body")
        
        NoteListItemView(note: $note)
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
                Image(systemName: "pencil.circle.fill")
                    .ListItemImageStyle()
                
                Text(note.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if note.starred {
                    Image(systemName: "star")
                        .foregroundColor(Color("AccentColor"))
                }
                
                Spacer()
                
                Button {
                    GlobalHelperDataService.copyToClipboard(note.body)
                    copyPopupOverlayViewModel.displayCopyPopupOverlay()
                } label: {
                    Image(systemName: "doc.circle.fill")
                        .ListItemImageStyle()
                }
            }
        }
        .modifier(ListItemStyle())
    }
}

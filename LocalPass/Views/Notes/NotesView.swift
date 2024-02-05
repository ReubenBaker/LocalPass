//
//  NotesView.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import SwiftUI

struct NotesView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var notesViewModel: NotesViewModel
    @State private var showDeleteAlert: Bool = false
    @State private var showNoteDetailSheet: Bool = false
    @State private var showAddNoteSheet: Bool = false
    @State private var sortSelection: String = ""
    
    var body: some View {
        ZStack {
            NavigationStack {
                if notesViewModel.notes == nil {
                    noNoteItem
                } else {
                    noteListItem
                }
            }
        }
        .fullScreenCover(isPresented: $showAddNoteSheet) {
            AddNoteView()
                .overlay(PrivacyOverlayView())
                .environment(\.scenePhase, scenePhase)
        }
        .alert(isPresented: $showDeleteAlert) {
            notesViewModel.getDeleteAlert() {}
        }
        .onChange(of: sortSelection) { newValue in
            notesViewModel.sortNotesByOption(&notesViewModel.notes, sortOption: newValue)
            notesViewModel.sortNotesByStar(&notesViewModel.notes)
        }
    }
}

// Preview
struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var notesViewModel = NotesViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        
        NotesView()
            .environmentObject(notesViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(privacyOverlayViewModel)
    }
}

// Views
extension NotesView {
    private var noteListItem: some View {
        List {
            if let notes = notesViewModel.notes {
                ForEach(notes) { note in
                    NoteListItemView(note: Binding.constant(note))
                        .environment(\.scenePhase, scenePhase)
                        .modifier(ParentViewListItemStyle())
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                notesViewModel.noteToDelete = note
                                showDeleteAlert.toggle()
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                            .tint(.red)
                            
                            Button {
                                if let index = notesViewModel.notes?.firstIndex(where: { $0.id == note.id }) {
                                    notesViewModel.notes?[index].starred.toggle()
                                    notesViewModel.sortNotesByStar(&notesViewModel.notes)
                                }
                            } label: {
                                Image(systemName: "star")
                            }
                            .tint(.yellow)
                        }
                    
                    EmptyListRowView()
                }
            }
        }
        .animation(.easeOut, value: notesViewModel.notes)
        .modifier(DataListStyle(type: "Notes"))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Picker("Sort", selection: $sortSelection) {
                        ForEach(GlobalHelperDataService.sortOptions, id: \.self) {
                            Text($0)
                        }
                    }
                } label: {
                    Text("Sort")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddNoteSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    private var noNoteItem: some View {
        VStack(alignment: .leading) {
            Text("You have no notes yet, time to add your first one! 🤩")
                .font(.title2)
                .padding()
            
            Button {
                showAddNoteSheet.toggle()
            } label: {
                Text("Add Your First Note")
                    .modifier(NoDataButtonStyle())
            }

            Spacer()
        }
        .navigationTitle("No Notes!")
    }
}

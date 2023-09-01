//
//  NotesView.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import SwiftUI

struct NotesView: View {
    
    @EnvironmentObject private var notesViewModel: NotesViewModel
    @State private var showDeleteAlert: Bool = false
    @State private var showNoteDetailSheet: Bool = false
    @State private var showAddNoteSheet: Bool = false
    @State private var sortSelection: String = ""
    private let sortOptions: [String] = [
        "Date Added Ascending", "Date Added Descending", "Alphabetical"
    ]
    
    var body: some View {
        ZStack {
            NavigationStack {
                if notesViewModel.notes == nil {
                    noNoteItem
                } else {
                    noteList
                }
            }
        }
        .fullScreenCover(isPresented: $showAddNoteSheet) {
            AddNoteView()
        }
        .alert(isPresented: $showDeleteAlert) {
            notesViewModel.getDeleteAlert()
        }
        .overlay {
            PrivacyOverlayView()
                .hidden() // Fix: Prevents strange behaviour of overlay in noteDetailView
        }
        .onChange(of: sortSelection) { _ in
            sortNotes(sortSelection: sortSelection)
        }
    }
}

// Preview
struct NotesView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var notesViewModel = NotesViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        
        NotesView()
            .environmentObject(mainViewModel)
            .environmentObject(notesViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(privacyOverlayViewModel)
    }
}

// Functions
extension NotesView {
    private func sortNotes(sortSelection: String) {
        if notesViewModel.notes != nil {
            notesViewModel.sortNotes(notes: &notesViewModel.notes, sortOption: sortSelection)
            notesViewModel.sortNotesByStar(notes: &notesViewModel.notes)
        }
    }
}

// Views
extension NotesView {
    private var noteList: some View {
        List {
            if let notes = notesViewModel.notes {
                ForEach(notes) { note in
                    NoteListItemView(note: Binding.constant(note))
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                notesViewModel.noteToDelete = note
                                showDeleteAlert.toggle()
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                            .tint(.red)
                            
                            if let index = notesViewModel.notes?.firstIndex(where: { $0.id == note.id }) {
                                Button {
                                    notesViewModel.notes?[index].starred.toggle()
                                    notesViewModel.sortNotesByStar(notes: &notesViewModel.notes)
                                } label: {
                                    Image(systemName: note.starred ? "star.fill" : "star")
                                }
                                .tint(.yellow)
                            }
                        }
                    
                    Spacer()
                        .listRowSeparator(.hidden)
                        .moveDisabled(true)
                }
            }
        }
        .padding(.horizontal)
        .environment(\.defaultMinListRowHeight, 0)
        .listStyle(PlainListStyle())
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .navigationTitle("Notes")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Picker("Sort", selection: $sortSelection) {
                        ForEach(sortOptions, id: \.self) {
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
        VStack {
            Text("You have no notes setup yet, time to add your first one! 🤩")
                .font(.title2)
                .padding()
            
            Button {
                showAddNoteSheet.toggle()
            } label: {
                Text("Add Your First Note")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .background(Color("AccentColor"))
                    .cornerRadius(10)
                    .shadow(radius: 4)
                    .padding()
            }

            Spacer()
        }
        .navigationTitle("No Notes!")
    }
}

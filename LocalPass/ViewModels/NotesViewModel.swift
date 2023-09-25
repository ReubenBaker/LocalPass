//
//  NotesViewModel.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import Foundation
import SwiftUI

class NotesViewModel: ObservableObject {    
    @Published var notes: [Note]? {
        didSet {
            NotesDataService.saveData(notes)
        }
    }
    
    @Published var noteToDelete: Note? = nil
    
    init() {
        let notes = NotesDataService.getNoteData()
        self.notes = notes
        
        if notes == nil {
            self.notes = NoteTestDataService.notes // REMOVE!
        }
    }
    
    func addNote(title: String, body: String) -> Bool {
        if title == "" || body == "" {
            return false
        }
        
        let newNote: Note = Note(
            title: title,
            body: body
        )
        
        if let notes = self.notes {
            self.notes = notes + [newNote]
        } else {
            self.notes = [newNote]
        }
        
        return true
    }
    
    func updateNote(id: UUID, note: Note) {
        if let index = notes?.firstIndex(where: { $0.id == id }) {
            notes?[index] = note
        }
    }
    
    func deleteNote(_ note: Note) {
        DispatchQueue.main.async {
            if self.notes?.count == 1 {
                self.notes = nil
            } else {
                self.notes?.removeAll(where: { $0.id == note.id })
            }
        }
    }
    
    func sortNotesByOption(_ notes: inout [Note]?, sortOption: String) {
        if let unsortedNotes = notes {
            var sortedNotes: [Note]? = nil
            
            if sortOption == "Date Added Ascending" {
                sortedNotes = unsortedNotes.sorted(by: { $0.creationDateTime.compare($1.creationDateTime) == .orderedAscending })
            } else if sortOption == "Date Added Descending" {
                sortedNotes = unsortedNotes.sorted(by: { $0.creationDateTime.compare($1.creationDateTime) == .orderedDescending })
            } else if sortOption == "Alphabetical" {
                sortedNotes = unsortedNotes.sorted(by: { $0.title.compare($1.title) == .orderedAscending })
            }
            
            notes = sortedNotes ?? notes
        }
    }
    
    func sortNotesByStar(_ notes: inout [Note]?) {
        if let unsortedNotes = notes {
            let starredNotes: [Note] = unsortedNotes.filter({ $0.starred })
            let unstarredNotes: [Note] = unsortedNotes.filter({ !$0.starred })
            
            notes = starredNotes + unstarredNotes
        }
    }
    
    func getDeleteAlert() -> Alert {
        let title: Text = Text("Are you sure you want to delete this note?")
        let message: Text = Text("This action cannot be undone!")
        let deleteButton: Alert.Button = .destructive(Text("Delete"), action: {
            if let note = self.noteToDelete {
                self.deleteNote(note)
                self.noteToDelete = nil
            }
        })
        let cancelButton: Alert.Button = .cancel()
        
        return Alert(
            title: title,
            message: message,
            primaryButton: deleteButton,
            secondaryButton: cancelButton
        )
    }
}

//
//  NotesViewModel.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import Foundation

class NotesViewModel: ObservableObject {
    @Published var notes: [Note]? {
        didSet {
            // Save data
        }
    }
    
    @Published var noteToDelete: Note? = nil
    
    init() {
        // Get data
    }
    
    func addNote(title: String, body: String) -> Bool {
        if title == "" || body == "" {
            return false
        }
        
        let newNote: Note = Note(
            title: title,
            body: body
        )
        
        notes = (notes ?? [] + [newNote])
        return true
    }
    
    func updateNote(id: String, note: Note) {
        if let index = notes?.firstIndex(where: { $0.id == id }) {
            notes?[index] = note
        }
    }
    
    func deleteNote(note: Note) {
        DispatchQueue.main.async {
            if self.notes?.count == 1 {
                self.notes = nil
            } else {
                self.notes?.removeAll(where: { $0.id == note.id })
            }
        }
    }
}

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
}

//
//  NoteModel.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import Foundation

struct Note: Identifiable, Equatable {
    var title: String
    var body: String
    let creationDateTime: Date
    var updatedDateTime: Date? = nil
    var starred: Bool
    
    // Identifiable
    var id: UUID = UUID()
    
    // Equatable
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
    
    init(title: String, body: String) {
        self.title = title
        self.body = body
        self.creationDateTime = Date()
        self.starred = false
    }
    
    init(title: String, body: String, creationDateTime: Date, updatedDateTime: Date?, starred: Bool, id: UUID) {
        self.title = title
        self.body = body
        self.creationDateTime = creationDateTime
        self.updatedDateTime = updatedDateTime
        self.starred = starred
        self.id = id
    }
}

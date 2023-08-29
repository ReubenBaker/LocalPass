//
//  AccountModel.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import Foundation
import SwiftUI

struct Account: Identifiable, Equatable {
    var name: String
    var username: String
    var password: String
    var url: String?
    let creationDateTime: Date
    var updatedDateTime: Date? = nil
    var starred: Bool
    
    // Identifiable
    var id: String {
        name + String(creationDateTime.description) // Change later
    }
    
    // Equatable
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }
    
    init(name: String, username: String, password: String, url: String? = nil) {
        self.name = name
        self.username = username
        self.password = password
        self.url = url
        self.creationDateTime = Date()
        self.starred = false
    }
}

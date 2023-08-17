//
//  AccountModel.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import Foundation

struct Account: Identifiable, Equatable {
    let name: String
    let username: String // Change!
    let password: String // Change!
    var url: String?
    let creationDateTime: Date = Date()
    let updatedDateTime: Date = Date()
    
    // Identifiable
    var id: String {
        name + username // Change later
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
    }
}

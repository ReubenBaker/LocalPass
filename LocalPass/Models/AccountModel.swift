//
//  AccountModel.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import Foundation

struct Account: Identifiable, Equatable {
    var name: String
    var username: String
    var password: String
    var url: String?
    let creationDateTime: Date
    var updatedDateTime: Date? = nil
    var starred: Bool
    var otpSecret: String?
    
    // Identifiable
    var id: String {
        name + String(creationDateTime.description) // Change later
    }
    
    // Equatable
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }
    
    init(name: String, username: String, password: String, url: String? = nil, otpSecret: String? = nil) {
        self.name = name
        self.username = username
        self.password = password
        self.url = url
        self.creationDateTime = Date()
        self.starred = false
        self.otpSecret = otpSecret
    }
    
    init(name: String, username: String, password: String, url: String?, creationDateTime: Date, updatedDateTime: Date?, starred: Bool, otpSecret: String?) {
        self.name = name
        self.username = username
        self.password = password
        self.url = url
        self.creationDateTime = creationDateTime
        self.updatedDateTime = updatedDateTime
        self.starred = starred
        self.otpSecret = otpSecret
    }
}

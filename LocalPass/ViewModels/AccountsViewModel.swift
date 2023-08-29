//
//  AccountsViewModel.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import Foundation
import SwiftUI

class AccountsViewModel: ObservableObject {
    // Test data
    @Published var testAccounts: [Account]
    
    @Published var accountToDelete: Account? = nil
    
    @Published var viewItemHeight: CGFloat = 50
    
    init() {
        let testAccounts = AccountTestDataService.accounts
        self.testAccounts = testAccounts
    }
    
    func addAccount(name: String, username: String, password: String, url: String? = nil) -> Bool {
        if name == "" || username == "" || password == "" {
            return false
        }
        
        let newAccount: Account = Account(
            name: name,
            username: username,
            password: password,
            url: url
        )
        do {
            testAccounts.append(newAccount)
            return true
        } catch {
            return false
        }
    }
    
    func updateAccount(id: String, account: Account) {
        if let index = testAccounts.firstIndex(where: { $0.id == id }) {
            testAccounts[index] = account
        }
    }
    
    func deleteItem(account: Account) {
        testAccounts.removeAll(where: { $0.id == account.id })
    }
    
    func getDeleteAlert() -> Alert {
        let title: Text = Text("Are you sure you want to delete this account?")
        let message: Text = Text("This action cannot be undone!")
        let deleteButton: Alert.Button = .destructive(Text("Delete"), action: {
            if self.accountToDelete != nil {
                self.deleteItem(account: self.accountToDelete!)
                self.accountToDelete = nil
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
    
    func sortAccounts(accounts: inout [Account], sortOption: String) {
        var sortedAccounts: [Account]? = nil
        
        if sortOption == "Date Added Ascending" {
            sortedAccounts = accounts.sorted(by: { $0.creationDateTime.compare($1.creationDateTime) == .orderedAscending })
        } else if sortOption == "Date Added Descending" {
            sortedAccounts = accounts.sorted(by: { $0.creationDateTime.compare($1.creationDateTime) == .orderedDescending })
        } else if sortOption == "Alphabetical" {
            sortedAccounts = accounts.sorted(by: { $0.name.compare($1.name) == .orderedAscending })
        }
        
        accounts = sortedAccounts ?? accounts
    }
    
    func sortAccountsByStar(accounts: inout [Account]) {
        let starredAccounts: [Account] = accounts.filter({ $0.starred })
        let unstarredAccounts: [Account] = accounts.filter({ !$0.starred })
        
        accounts = starredAccounts + unstarredAccounts
    }
}

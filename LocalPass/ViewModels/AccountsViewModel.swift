//
//  AccountsViewModel.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import Foundation
import SwiftUI

class AccountsViewModel: ObservableObject {
    @Published var accounts: [Account]? {
        didSet {
            AccountsDataService().saveData(accounts: accounts)
        }
    }
    
    @Published var accountToDelete: Account? = nil
    
    init() {
        let accounts = AccountsDataService().getAccountData()
        self.accounts = accounts
        
        if accounts == nil { // Remove later!!
            self.accounts = AccountTestDataService.accounts
        }
    }
    
    func addAccount(name: String, username: String, password: String, url: String? = nil, otpSecret: String? = nil) -> Bool {
        if name == "" || username == "" || password == "" {
            return false
        }
        
        let newAccount: Account = Account(
            name: name,
            username: username,
            password: password,
            url: url,
            otpSecret: otpSecret
        )
        
        accounts = (accounts ?? []) + [newAccount]
        return true
    }
    
    func updateAccount(id: UUID, account: Account) {
        if let index = accounts?.firstIndex(where: { $0.id == id }) {
            accounts?[index] = account
        }
    }
    
    func deleteAccount(account: Account) {
        DispatchQueue.main.async {
            if self.accounts?.count == 1 {
                self.accounts = nil
            } else {
                self.accounts?.removeAll(where: { $0.id == account.id })
            }
        }
    }
    
    func getDeleteAlert() -> Alert {
        let title: Text = Text("Are you sure you want to delete this account?")
        let message: Text = Text("This action cannot be undone!")
        let deleteButton: Alert.Button = .destructive(Text("Delete"), action: {
            if self.accountToDelete != nil {
                self.deleteAccount(account: self.accountToDelete!)
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
    
    func sortAccounts(accounts: inout [Account]?, sortOption: String) {
        if let unsortedAccounts = accounts {
            var sortedAccounts: [Account]? = nil
            
            if sortOption == "Date Added Ascending" {
                sortedAccounts = unsortedAccounts.sorted(by: { $0.creationDateTime.compare($1.creationDateTime) == .orderedAscending })
            } else if sortOption == "Date Added Descending" {
                sortedAccounts = unsortedAccounts.sorted(by: { $0.creationDateTime.compare($1.creationDateTime) == .orderedDescending })
            } else if sortOption == "Alphabetical" {
                sortedAccounts = unsortedAccounts.sorted(by: { $0.name.compare($1.name) == .orderedAscending })
            }
            
            accounts = sortedAccounts ?? accounts
        }
    }
    
    func sortAccountsByStar(accounts: inout [Account]?) {
        if let unsortedAccounts = accounts {
            let starredAccounts: [Account] = unsortedAccounts.filter({ $0.starred })
            let unstarredAccounts: [Account] = unsortedAccounts.filter({ !$0.starred })
            
            accounts = starredAccounts + unstarredAccounts
        }
    }
}

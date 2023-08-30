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
    
    @Published var viewItemHeight: CGFloat = 50
    
    init() {
        let accountsDataService = AccountsDataService() // Remove later + remove init of test accounts
        let accounts = AccountsDataService().getAccountData()
        self.accounts = accounts
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
        
        accounts = (accounts ?? []) + [newAccount]
        return true
    }
    
    func updateAccount(id: String, account: Account) {
        if let index = accounts?.firstIndex(where: { $0.id == id }) {
            accounts![index] = account
        }
    }
    
    func deleteItem(account: Account) {
        accounts?.removeAll(where: { $0.id == account.id })
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

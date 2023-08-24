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
    
    // Selected account
    @Published var selectedAccount: Account? = nil
    
    @Published var accountToDelete: Account? = nil
    
    @Published var viewItemHeight: CGFloat = 55
    
    init() {
        let testAccounts = AccountTestDataService.accounts
        self.testAccounts = testAccounts
    }
    
    func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
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
    
    func updateAccount(index: Int) {
        if selectedAccount != nil {
            testAccounts[index] = selectedAccount!
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
                self.selectedAccount = nil
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

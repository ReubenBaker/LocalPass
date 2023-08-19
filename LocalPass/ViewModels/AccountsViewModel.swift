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
    
    @Published var defaultAccount: Account = Account(name: "default", username: "default", password: "default", url: "default")
    
    init() {
        let testAccounts = AccountTestDataService.accounts
        self.testAccounts = testAccounts
    }
    
    func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
    }
    
    func updateAccount(index: Int) {
        if selectedAccount != nil {
            testAccounts[index] = selectedAccount!
        }
    }
}

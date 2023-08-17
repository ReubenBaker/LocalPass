//
//  AccountViewModel.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import Foundation

class AccountViewModel: ObservableObject {
    // Test data
    @Published var testAccounts: [Account]
    
    // Selected account
    @Published var selectedAccount: Account? = nil
    
    init() {
        let testAccounts = AccountTestDataService.accounts
        self.testAccounts = testAccounts
    }
}

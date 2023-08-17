//
//  AccountViewModel.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import Foundation
import SwiftUI

class AccountViewModel: ObservableObject {
    // Test data
    @Published var testAccounts: [Account]
    
    // Selected account
    @Published var selectedAccount: Account? = nil
    
    init() {
        let testAccounts = AccountTestDataService.accounts
        self.testAccounts = testAccounts
    }
    
    func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
    }
}

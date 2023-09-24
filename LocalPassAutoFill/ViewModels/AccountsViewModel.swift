//
//  AccountsViewModel.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI

class AccountsViewModel: ObservableObject {
    @Published var accounts: [Account]?
    
    init() {
        let accounts = AccountsDataService.getAccountData()
        self.accounts = accounts
    }
}

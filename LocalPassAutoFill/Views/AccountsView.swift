//
//  AccountsView.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 24/09/2023.
//

import SwiftUI

struct AccountsView: View {
    
    var autoFill: (() -> Void)?
    @StateObject private var accountsViewModel = AccountsViewModel()
    
    var body: some View {
        ZStack {
            if accountsViewModel.accounts == nil {
                noAccountItem
            } else {
                accountListItem
            }
        }
        .modifier(SignUpViewStyle())
    }
}

// Views
extension AccountsView {
    private var accountListItem: some View {
        ScrollView {
            Text("Accounts")
                .padding(.top)
                .font(.title)
            
            if let accounts = accountsViewModel.accounts {
                ForEach(accounts) { account in
                    AccountListItemView(autoFill: autoFill, account: Binding.constant(account))
                        .padding(.vertical)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.hidden)
        .padding(.bottom)
    }
    
    private var noAccountItem: some View {
        VStack {
            Text("You don't have any accounts setup in the LocalPass app yet! 😢\n\nFollow the setup instructions there and then come back! 🤩")
            
            Image("AppIconImageRoundedCorners")
                .LogoIconStyle()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.top)
        .font(.headline)
    }
}

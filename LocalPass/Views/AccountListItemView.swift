//
//  AccountListItemView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountListItemView: View {
    
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @Binding var account: Account
    
    var body: some View {
        Button {
            accountsViewModel.selectedAccount = account
        } label: {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(account.name)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    accountsViewModel.copyToClipboard(text: account.password)
                } label: {
                    Image(systemName: "lock.circle.fill")
                        .resizable()
                        .scaledToFit()
                }
            }
            .foregroundColor(.primary)
            .padding()
        }
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(Color("AccentColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct AccountListItemView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        AccountListItemView(account: $accountsViewModel.testAccounts.first!)
            .environmentObject(accountsViewModel)
    }
}

//
//  AccountsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountsView: View {
    
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    
    var body: some View {
        ZStack {
            accountList
        }
        .sheet(item: $accountsViewModel.selectedAccount, onDismiss: nil) { _ in 
            AccountDetailView()
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        AccountsView()
            .environmentObject(accountsViewModel)
    }
}

extension AccountsView {
    private var accountList: some View {
        NavigationStack {
            ScrollView {
                ForEach($accountsViewModel.testAccounts) { $account in
                    AccountListItemView(account: $account)
                        .padding(.vertical, 4)
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Edit")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("+")
                }
            }
        }
    }
    
//    private var createAccount: some View {
//        Button {
//
//        } label: {
//            Image(systemName: "plus")
//                .font(.headline)
//                .padding()
//                .foregroundColor(.primary)
//                .background(.thickMaterial)
//                .cornerRadius(10)
//                .shadow(radius: 4)
//        }
//    }
}

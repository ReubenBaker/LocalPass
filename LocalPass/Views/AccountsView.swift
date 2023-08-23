//
//  AccountsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountsView: View {
    
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @State private var showDeleteAlert: Bool = false
    @State private var showAddAccountSheet: Bool = false
    
    var body: some View {
        ZStack {
            accountList
        }
        .sheet(item: $accountsViewModel.selectedAccount, onDismiss: nil) { _ in
            AccountDetailView()
        }
        .sheet(isPresented: $showAddAccountSheet, content: {
            AddAccountView()
        })
        .alert(isPresented: $showDeleteAlert) {
            accountsViewModel.getDeleteAlert()
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

// Functions
extension AccountsView {

}

// Views
extension AccountsView {
    private var accountList: some View {
         NavigationStack {
             List {
                ForEach($accountsViewModel.testAccounts) { $account in
                    AccountListItemView(account: $account)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .padding(.horizontal)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                accountsViewModel.accountToDelete = account
                                showDeleteAlert.toggle()
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                            .tint(.red)
                        }
                        
                   Spacer()
                        .listRowSeparator(.hidden)
                }
            }
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(PlainListStyle())
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddAccountSheet.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
        }
    }
}

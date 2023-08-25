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
    @State private var showAccountDetailSheet: Bool = false
    @State private var showAddAccountSheet: Bool = false
    
    var body: some View {
        ZStack {
            accountList
        }
        .fullScreenCover(isPresented: $showAddAccountSheet, content: {
            AddAccountView()
        })
        .alert(isPresented: $showDeleteAlert) {
            accountsViewModel.getDeleteAlert()
        }
        .overlay(alignment: .top) {
            CopyPopupOverlayView()
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                accountsViewModel.accountToDelete = account
                                showDeleteAlert.toggle()
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                            .tint(.red)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                if let index = accountsViewModel.testAccounts.firstIndex(where: { $0.id == account.id }) {
                                    accountsViewModel.testAccounts[index].starred.toggle()
                                    accountsViewModel.sortAccountsByStar(accounts: &accountsViewModel.testAccounts)
                                }
                            } label: {
                                Image(systemName: "star.fill")
                            }
                            .tint(.yellow)
                        }
                    
                   Spacer()
                        .listRowSeparator(.hidden)
                }
            }
            .padding(.horizontal)
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        accountsViewModel.displayCopyPopupOverlay()
                    } label: {
                        Text("PU Tog")
                    }

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

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
    @State private var accountToDelete: Account?
    
    var body: some View {
        ZStack {
            accountList
        }
        .sheet(item: $accountsViewModel.selectedAccount, onDismiss: nil) { _ in 
            AccountDetailView()
        }
        .alert(isPresented: $showDeleteAlert) {
            getDeleteAlert()
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
    private func getDeleteAlert() -> Alert {
        let title: Text = Text("Are you sure you want to delete this account?")
        let message: Text = Text("This action cannot be undone!")
        let deleteButton: Alert.Button = .destructive(Text("Delete"), action: {
            if accountToDelete != nil {
                deleteItem(account: accountToDelete!)
                accountToDelete = nil
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
    
    private func deleteItem(account: Account) {
        accountsViewModel.testAccounts.removeAll(where: { $0.id == account.id })
    }
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
                                accountToDelete = account
                                showDeleteAlert.toggle()
                            } label: {
                                Image(systemName: "trash.fill")
                            }
                            .tint(.red)
                        }
                        
                   Spacer()
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
                    Text("+")
                }
            }
        }
    }
}

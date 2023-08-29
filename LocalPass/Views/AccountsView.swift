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
    @State private var sortSelection: String = ""
    
    private let sortOptions: [String] = [
        "Date Added Ascending", "Date Added Descending", "Alphabetical"
    ]
    
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
        .overlay {
            PrivacyOverlayView()
                .hidden()
        }
        .onChange(of: sortSelection) { _ in
            accountsViewModel.sortAccounts(accounts: &accountsViewModel.testAccounts, sortOption: sortSelection)
            accountsViewModel.sortAccountsByStar(accounts: &accountsViewModel.testAccounts)
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
                            
                            if let index = accountsViewModel.testAccounts.firstIndex(where: { $0.id == account.id }) {
                                Button {
                                    accountsViewModel.testAccounts[index].starred.toggle()
                                    accountsViewModel.sortAccountsByStar(accounts: &accountsViewModel.testAccounts)
                                } label: {
                                    Image(systemName: accountsViewModel.testAccounts[index].starred ? "star.fill" : "star")
                                }
                                .tint(.yellow)
                            }
                        }
                    
                   Spacer()
                        .listRowSeparator(.hidden)
                        .moveDisabled(true)
                }
            }
            .padding(.horizontal)
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("Sort", selection: $sortSelection) {
                            ForEach(sortOptions, id: \.self) {
                                Text($0)
                            }
                        }
                    } label: {
                        Text("Sort")
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

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
        .overlay {
            PrivacyOverlayView()
                .hidden() // Fix: Prevents strange behaviour of overlay in accountDetailView
        }
        .onChange(of: sortSelection) { _ in
            sortAccounts(sortSelection: sortSelection)
        }
    }
}

// Preview
struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        
        AccountsView()
            .environmentObject(accountsViewModel)
            .environmentObject(privacyOverlayViewModel)
    }
}

// Functions
extension AccountsView {
    private func sortAccounts(sortSelection: String) {
        if accountsViewModel.testAccounts != nil {
            accountsViewModel.sortAccounts(accounts: &accountsViewModel.testAccounts, sortOption: sortSelection)
            accountsViewModel.sortAccountsByStar(accounts: &accountsViewModel.testAccounts)
        }
    }
}

// Views
extension AccountsView {
    private var accountList: some View {
         NavigationStack {
             List {
                 if let accounts = accountsViewModel.testAccounts {
                     ForEach(accounts) { account in
                         AccountListItemView(account: Binding.constant(account))
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
                                
                                if let index = accountsViewModel.testAccounts!.firstIndex(where: { $0.id == account.id }) {
                                    Button {
                                        accountsViewModel.testAccounts![index].starred.toggle()
                                        accountsViewModel.sortAccountsByStar(accounts: &accountsViewModel.testAccounts)
                                    } label: {
                                        Image(systemName: account.starred ? "star.fill" : "star")
                                    }
                                    .tint(.yellow)
                                }
                            }
                        
                       Spacer()
                            .listRowSeparator(.hidden)
                            .moveDisabled(true)
                     }
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

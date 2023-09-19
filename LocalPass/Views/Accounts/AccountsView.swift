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
            NavigationStack {
                if accountsViewModel.accounts == nil {
                    noAccountItem
                } else {
                    accountList
                }
            }
        }
        .fullScreenCover(isPresented: $showAddAccountSheet) {
            AddAccountView()
                .overlay(PrivacyOverlayView())
        }
        .alert(isPresented: $showDeleteAlert) {
            accountsViewModel.getDeleteAlert()
        }
        .onChange(of: sortSelection) { _ in
            sortAccounts(sortSelection: sortSelection)
        }
    }
}

// Preview
struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var accountsViewModel = AccountsViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        
        AccountsView()
            .environmentObject(mainViewModel)
            .environmentObject(accountsViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(privacyOverlayViewModel)
    }
}

// Functions
extension AccountsView {
    private func sortAccounts(sortSelection: String) {
        if accountsViewModel.accounts != nil {
            accountsViewModel.sortAccounts(accounts: &accountsViewModel.accounts, sortOption: sortSelection)
            accountsViewModel.sortAccountsByStar(accounts: &accountsViewModel.accounts)
        }
    }
}

// Views
extension AccountsView {
    private var accountList: some View {
         List {
             if let accounts = accountsViewModel.accounts {
                 ForEach(accounts) { account in
                     AccountListItemView(account: Binding.constant(account))
                        .overlay(PrivacyOverlayView())
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
                            
                            if let index = accountsViewModel.accounts?.firstIndex(where: { $0.id == account.id }) {
                                Button {
                                    accountsViewModel.accounts?[index].starred.toggle()
                                    accountsViewModel.sortAccountsByStar(accounts: &accountsViewModel.accounts)
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
    
    private var noAccountItem: some View {
        VStack {
            Text("You have no accounts setup yet, time to add your first one! 🤩")
                .font(.title2)
                .padding()
            
            Button {
                showAddAccountSheet.toggle()
            } label: {
                Text("Add Your First Account")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.primary)
                    .background(Color("AccentColor"))
                    .cornerRadius(10)
                    .shadow(radius: 4)
                    .padding()
            }

            Spacer()
        }
        .navigationTitle("No Accounts!")
    }
}

//
//  AccountsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountsView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @State private var showDeleteAlert: Bool = false
    @State private var showAccountDetailSheet: Bool = false
    @State private var showAddAccountSheet: Bool = false
    @State private var sortOption: String = ""
    
    var body: some View {
        ZStack {
            NavigationStack {
                if accountsViewModel.accounts == nil {
                    noAccountItem
                } else {
                    accountListItem
                }
            }
        }
        .fullScreenCover(isPresented: $showAddAccountSheet) {
            AddAccountView()
                .overlay(PrivacyOverlayView())
                .environment(\.scenePhase, scenePhase)
        }
        .alert(isPresented: $showDeleteAlert) {
            accountsViewModel.getDeleteAlert()
        }
        .onChange(of: sortOption) { newValue in
            accountsViewModel.sortAccountsByOption(&accountsViewModel.accounts, sortOption: newValue)
            accountsViewModel.sortAccountsByStar(&accountsViewModel.accounts)
        }
    }
}

// Preview
struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        
        AccountsView()
            .environmentObject(accountsViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(privacyOverlayViewModel)
    }
}

// Views
extension AccountsView {
    private var accountListItem: some View {
         List {
             if let accounts = accountsViewModel.accounts {
                 ForEach(accounts) { account in
                     AccountListItemView(account: Binding.constant(account))
                         .modifier(ParentViewListItemStyle())
                         .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                             Button {
                                 accountsViewModel.accountToDelete = account
                                 showDeleteAlert.toggle()
                             } label: {
                                 Image(systemName: "trash.fill")
                             }
                             .tint(.red)
                             
                             Button {
                                 if let index = accountsViewModel.accounts?.firstIndex(where: { $0.id == account.id }) {
                                     accountsViewModel.accounts?[index].starred.toggle()
                                     accountsViewModel.sortAccountsByStar(&accountsViewModel.accounts)
                                 }
                             } label: {
                                 Image(systemName: "star")
                             }
                             .tint(.yellow)
                         }
                     
                     EmptyListRowView()
                 }
             }
        }
        .animation(.easeOut, value: accountsViewModel.accounts)
        .modifier(DataListStyle(type: "Accounts"))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Picker("Sort", selection: $sortOption) {
                        ForEach(GlobalHelperDataService.sortOptions, id: \.self) {
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
        VStack(alignment: .leading) {
            Text("You have no accounts setup yet, time to add your first one! 🤩")
                .font(.title2)
                .padding()
            
            Button {
                showAddAccountSheet.toggle()
            } label: {
                Text("Add Your First Account")
                    .modifier(NoDataButtonStyle())
            }

            Spacer()
        }
        .navigationTitle("No Accounts!")
    }
}

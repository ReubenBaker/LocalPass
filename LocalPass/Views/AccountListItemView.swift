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
    @State var showAccountDetailViewSheet: Bool = false
    
    var body: some View {
        Button {
            showAccountDetailViewSheet.toggle()
        } label: {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(account.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    accountsViewModel.copyToClipboard(text: account.password)
                    accountsViewModel.displayCopyPopupOverlay()
                } label: {
                    Image(systemName: "lock.circle.fill")
                        .resizable()
                        .scaledToFit()
                }
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .sheet(isPresented: $showAccountDetailViewSheet) {
                AccountDetailView(account: $account)
            }
        }
        .frame(height: accountsViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
    }
}

struct AccountListItemView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        AccountListItemView(account: $accountsViewModel.testAccounts.first!)
            .environmentObject(accountsViewModel)
    }
}

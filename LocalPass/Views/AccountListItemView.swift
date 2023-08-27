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
                Image(systemName: account.starred ? "star.fill" : "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("AccentColor"))
                
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
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .frame(height: accountsViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .fullScreenCover(isPresented: $showAccountDetailViewSheet) {
            AccountDetailView(account: $account)
        }
    }
}

struct AccountListItemView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        AccountListItemView(account: $accountsViewModel.testAccounts.first!)
            .environmentObject(accountsViewModel)
    }
}

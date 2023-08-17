//
//  AccountListItemView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountListItemView: View {
    
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @Binding var account: Account
    @State var showAccountDetailView: Bool = false
    
    var body: some View {
        Button {
            accountViewModel.selectedAccount = account
        } label: {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(account.name)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "lock.circle.fill")
                        .resizable()
                        .scaledToFit()
                }
            }
            .foregroundColor(.primary)
            .padding()
        }
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(Color("AccentColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct AccountListItemView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountViewModel = AccountViewModel()
        AccountListItemView(account: $accountViewModel.testAccounts.first!)
            .environmentObject(accountViewModel)
    }
}

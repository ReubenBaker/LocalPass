//
//  AccountsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountsView: View {
    
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @State var showAccountDetailView: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                ForEach($accountViewModel.testAccounts) { $account in
                    AccountListItemView(account: $account)
                        .padding(.vertical, 4)
                }
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct AccountsView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountViewModel = AccountViewModel()
        AccountsView()
            .environmentObject(accountViewModel)
    }
}

extension AccountsView {
    var accountList: some View {
        ScrollView {
//            ForEach(
        }
    }
}

//
//  AccountListItemView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountListItemView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @EnvironmentObject private var copyPopupOverlayViewModel: CopyPopupOverlayViewModel
    @Binding var account: Account
    @State private var showAccountDetailViewSheet: Bool = false
    
    var body: some View {
        accountListItem
        .fullScreenCover(isPresented: $showAccountDetailViewSheet) {
            AccountDetailView(account: $account)
        }
    }
}

// Preview
struct AccountListItemView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var accountsViewModel = AccountsViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        @State var account = Account(name: "default", username: "default", password: "default")
        
        AccountListItemView(account: $account)
            .environmentObject(mainViewModel)
            .environmentObject(accountsViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(privacyOverlayViewModel)
    }
}

// Views
extension AccountListItemView {
    private var accountListItem: some View {
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
                    mainViewModel.copyToClipboard(text: account.password)
                    copyPopupOverlayViewModel.displayCopyPopupOverlay()
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
    }
}

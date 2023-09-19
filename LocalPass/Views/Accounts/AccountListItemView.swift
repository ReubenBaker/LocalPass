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
                    .overlay(PrivacyOverlayView())
            }
    }
}

// Preview
struct AccountListItemView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var accountsViewModel = AccountsViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @State var account = Account(name: "default", username: "default", password: "default", url: "apple.com")
        
        AccountListItemView(account: $account)
            .environmentObject(mainViewModel)
            .environmentObject(accountsViewModel)
            .environmentObject(copyPopupOverlayViewModel)
    }
}

// Views
extension AccountListItemView {
    private var accountListItem: some View {
        Button {
            showAccountDetailViewSheet.toggle()
        } label: {
            HStack {
                if let url = account.url {
                    if Settings.shared.showFavicons {
                        FaviconImageView(url: url)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color("AccentColor"))
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("AccentColor"))
                }
                
                Text(account.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if account.starred {
                    Image(systemName: "star")
                }
                
                Spacer()
                
                Button {
                    GlobalHelperDataService.copyToClipboard(text: account.password)
                    copyPopupOverlayViewModel.displayCopyPopupOverlay()
                } label: {
                    Image(systemName: "lock.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("AccentColor"))
                }
            }
        }
        .modifier(ListItemStyle())
    }
}

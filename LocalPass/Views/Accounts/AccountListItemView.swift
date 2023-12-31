//
//  AccountListItemView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountListItemView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var copyPopupOverlayViewModel: CopyPopupOverlayViewModel
    @Binding var account: Account
    @State private var showAccountDetailViewSheet: Bool = false
    
    var body: some View {
        accountListItem
            .fullScreenCover(isPresented: $showAccountDetailViewSheet) {
                AccountDetailView(account: $account)
                    .overlay(PrivacyOverlayView())
                    .environment(\.scenePhase, scenePhase)
            }
            .onChange(of: scenePhase) { phase in
                if phase != .active && LocalPassApp.settings.lockVaultOnBackground {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showAccountDetailViewSheet = false
                    }
                }
            }
    }
}

// Preview
struct AccountListItemView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @State var account = Account(name: "default", username: "default", password: "default", url: "apple.com")
        
        AccountListItemView(account: $account)
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
                    if LocalPassApp.settings.showFavicons {
                        FaviconImageView(url: url)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .ListItemImageStyle()
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .ListItemImageStyle()
                }
                
                Text(account.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                if account.starred {
                    Image(systemName: "star")
                }
                
                Spacer()
                
                Button {
                    GlobalHelperDataService.copyToClipboard(account.password)
                    copyPopupOverlayViewModel.displayCopyPopupOverlay()
                } label: {
                    Image(systemName: "lock.circle.fill")
                        .ListItemImageStyle()
                }
            }
        }
        .modifier(ListItemStyle())
    }
}

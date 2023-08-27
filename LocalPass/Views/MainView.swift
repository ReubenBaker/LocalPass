//
//  MainView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct MainView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var accountsViewModel = AccountsViewModel()
    @State private var selectedTab: Int = 0
    @State private var showPrivacyOverlay: Bool = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                AccountsView()
                    .tabItem {
                        Label("Accounts", systemImage: "lock.rectangle.stack.fill")
                    }
                    .tag(0)
                    .environmentObject(accountsViewModel)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(1)
            }
        }
        .overlay {
            PrivacyOverlayView()
                .environmentObject(accountsViewModel)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive || newPhase == .background {
                withAnimation(.easeInOut(duration: 0.3)) {
                    accountsViewModel.privacyOverlaySize = UIScreen.main.bounds.height
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    accountsViewModel.privacyOverlaySize = 0
                }
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        
        MainView()
            .environmentObject(accountsViewModel)
    }
}

extension MainView {
    
}

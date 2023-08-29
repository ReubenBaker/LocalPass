//
//  MainView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject private var mainViewModel: MainViewModel
    @StateObject private var accountsViewModel = AccountsViewModel()
    @State private var selectedTab: Int = 0
    
    var body: some View {
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
        .overlay {
            PrivacyOverlayView()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        
        MainView()
            .environmentObject(mainViewModel)
    }
}

extension MainView {
    
}

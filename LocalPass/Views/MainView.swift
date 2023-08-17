//
//  MainView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct MainView: View {
    
    @StateObject private var accountsViewModel = AccountsViewModel()
    @State var selectedTab: Int = 0
    
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
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

extension MainView {
    
}

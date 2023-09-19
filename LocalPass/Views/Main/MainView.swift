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
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        mainTabView
    }
}

// Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        
        MainView()
            .environmentObject(mainViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(privacyOverlayViewModel)
    }
}

// Views
extension MainView {
    private var mainTabView: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                AccountsView()
                    .tabItem {
                        Label("Accounts", systemImage: "lock.rectangle.stack.fill")
                    }
                    .environmentObject(accountsViewModel)
                    .tag(0)
                
                NotesView()
                    .tabItem {
                        Label("Notes", systemImage: "sparkles.rectangle.stack.fill")
                    }
                    .environmentObject(notesViewModel)
                    .tag(1)
                    .toolbar(.visible, for: .tabBar)
                    .toolbarBackground(.ultraThinMaterial, for: .tabBar)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(2)
            }
        }
        .overlay(PrivacyOverlayView())
        .overlay(CopyPopupOverlayView(), alignment: .top)
    }
}

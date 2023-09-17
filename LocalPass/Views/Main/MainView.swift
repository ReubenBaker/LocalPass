//
//  MainView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct MainView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var copyPopupOverlayViewModel: CopyPopupOverlayViewModel
    @StateObject private var accountsViewModel = AccountsViewModel()
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            mainTabView
                .overlay(alignment: .top) {
                    CopyPopupOverlayView()
                }
        }
        .overlay(PrivacyOverlayView())
    }
}

// Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var settings = Settings()
        
        MainView()
            .environmentObject(mainViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(settings)
    }
}

// Views
extension MainView {
    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "lock.rectangle.stack.fill")
                }
                .tag(0)
                .environmentObject(accountsViewModel)
            
            NotesView()
                .tabItem {
                    Label("Notes", systemImage: "sparkles.rectangle.stack.fill")
                }
                .tag(1)
                .environmentObject(notesViewModel)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

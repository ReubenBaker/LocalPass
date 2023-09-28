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
    @StateObject private var notesViewModel = NotesViewModel()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        mainTabView
    }
}

// Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        
        MainView()
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
                    .environment(\.scenePhase, scenePhase)
                    .tag(0)
                
                NotesView()
                    .tabItem {
                        Label("Notes", systemImage: "sparkles.rectangle.stack.fill")
                    }
                    .environmentObject(notesViewModel)
                    .environment(\.scenePhase, scenePhase)
                    .tag(1)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .environment(\.scenePhase, scenePhase)
                    .tag(2)
            }
        }
        .overlay(PrivacyOverlayView())
        .overlay(CopyPopupOverlayView(), alignment: .top)
    }
}

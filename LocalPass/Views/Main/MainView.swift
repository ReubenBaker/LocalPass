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
    @EnvironmentObject private var privacyOverlayViewModel: PrivacyOverlayViewModel
    @StateObject private var accountsViewModel = AccountsViewModel()
    @StateObject private var notesViewModel = NotesViewModel()
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @State private var selectedTab: Int = 0
    @State private var authenticationStatus: Bool = false
    
    var body: some View {
        ZStack {
            if authenticationStatus {
                mainTabView
                    .overlay(alignment: .top) {
                        CopyPopupOverlayView()
                    }
                    .overlay {
                        PrivacyOverlayView()
                    }
                    .onChange(of: scenePhase) { newPhase in
                        if newPhase == .inactive || newPhase == .background {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                privacyOverlayViewModel.showPrivacyOverlay = true
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                privacyOverlayViewModel.showPrivacyOverlay = false
                            }
                        }
                    }
            } else {
                AuthenticationView()
                    .environmentObject(authenticationViewModel)
                    .environmentObject(accountsViewModel)
                    .onChange(of: authenticationViewModel.authenticated) { authenticatedStatus in
                        authenticationStatus = authenticatedStatus
                    }
            }
        }
        .animation(.easeInOut, value: authenticationStatus)
    }
}

// Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        @StateObject var settings = Settings()
        
        MainView()
            .environmentObject(mainViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(privacyOverlayViewModel)
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

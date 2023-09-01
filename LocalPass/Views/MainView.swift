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
    @State private var selectedTab: Int = 0
    
    var body: some View {
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

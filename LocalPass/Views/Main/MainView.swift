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
        ZStack {
            TabView(selection: Binding.constant(0)) {
                AccountsView()
                    .tabItem {
                        Label("Accounts", systemImage: "lock.rectangle.stack.fill")
                    }
                    .environmentObject(accountsViewModel)
                
                NotesView()
                    .tabItem {
                        Label("Notes", systemImage: "sparkles.rectangle.stack.fill")
                    }
                    .environmentObject(notesViewModel)
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
        .overlay(PrivacyOverlayView())
        .overlay(CopyPopupOverlayView(), alignment: .top)
    }
}

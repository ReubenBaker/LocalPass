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
    @State private var privacyOverlaySize: CGFloat = 0
    
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
            VStack {
                Spacer()
                    .frame(width: .infinity, height: UIScreen.main.bounds.height - privacyOverlaySize)
                
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: .infinity, height: privacyOverlaySize)
                    .background(.ultraThinMaterial).ignoresSafeArea()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive || newPhase == .background {
                withAnimation(.easeInOut(duration: 0.3)) {
                    privacyOverlaySize = .infinity
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    privacyOverlaySize = 0
                }
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

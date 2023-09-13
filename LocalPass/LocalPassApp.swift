//
//  LocalPassApp.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

@main
struct LocalPassApp: App {
    
    @StateObject private var mainViewModel = MainViewModel()
    @StateObject private var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
    @StateObject private var privacyOverlayViewModel = PrivacyOverlayViewModel()
    @StateObject private var settings = Settings()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            if settings.signedUp {
                MainView()
                    .environmentObject(mainViewModel)
                    .environmentObject(copyPopupOverlayViewModel)
                    .environmentObject(privacyOverlayViewModel)
                    .environmentObject(settings)
            } else {
                VStack {
                    SignUpRootView()
                }
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase != .active {
                withAnimation(.easeInOut) {
                    privacyOverlayViewModel.showPrivacyOverlay = true
                }
            } else {
                withAnimation(.easeInOut) {
                    privacyOverlayViewModel.showPrivacyOverlay = false
                }
            }
        }
    }
}

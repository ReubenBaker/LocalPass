//
//  LocalPassApp.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

@main
struct LocalPassApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var mainViewModel = MainViewModel()
    @StateObject private var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
    @StateObject private var privacyOverlayViewModel = PrivacyOverlayViewModel()
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @StateObject private var settings = Settings()
    @State private var authenticationStatus: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if settings.signedUp {
                ZStack {
                    if authenticationStatus {
                        MainView()
                            .environmentObject(mainViewModel)
                            .environmentObject(copyPopupOverlayViewModel)
                            .environmentObject(privacyOverlayViewModel)
                            .environmentObject(settings)
                    } else {
                        AuthenticationView()
                            .environmentObject(authenticationViewModel)
                    }
                }
                .animation(.easeInOut, value: authenticationStatus)
            } else {
                VStack {
                    SignUpRootView()
                }
            }
        }
        .onChange(of: authenticationViewModel.authenticated) { authenticatedStatus in
            authenticationStatus = authenticatedStatus
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

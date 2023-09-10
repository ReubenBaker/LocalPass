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
    
    var body: some Scene {
        WindowGroup {
            if settings.signedUp {
                MainView()
                    .environmentObject(mainViewModel)
                    .environmentObject(copyPopupOverlayViewModel)
                    .environmentObject(privacyOverlayViewModel)
            } else {
                VStack {
                    SignUpRootView()
                }
            }
        }
    }
}

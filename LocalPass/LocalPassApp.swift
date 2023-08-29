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
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(mainViewModel)
                .environmentObject(copyPopupOverlayViewModel)
                .environmentObject(privacyOverlayViewModel)
        }
    }
}

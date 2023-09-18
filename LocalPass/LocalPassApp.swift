//
//  LocalPassApp.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

/**
 LocalPass
     Copyright (C) 2023 - Reuben Baker

     This program is free software: you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation, either version 3 of the License, or
     (at your option) any later version.

     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.

     You should have received a copy of the GNU General Public License
     along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
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
            ZStack {
                if settings.signedUp {
                    ZStack {
                        if authenticationStatus {
                            MainView()
                                .environmentObject(mainViewModel)
                                .environmentObject(copyPopupOverlayViewModel)
                                .environmentObject(privacyOverlayViewModel)
                                .environmentObject(authenticationViewModel)
                                .environmentObject(settings)
                        } else {
                            AuthenticationView()
                                .environmentObject(authenticationViewModel)
                        }
                    }
                    .animation(.easeInOut, value: authenticationStatus)
                } else {
                    SignUpView()
                        .environmentObject(authenticationViewModel)
                        .environmentObject(settings)
                }
            }
            .animation(.easeInOut, value: settings.signedUp)
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

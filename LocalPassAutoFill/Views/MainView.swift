//
//  MainView.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 23/09/2023.
//

import SwiftUI
import AuthenticationServices

struct MainView: View {
    
    @ObservedObject var credentialProviderViewModel: CredentialProviderViewModel
    var autoFill: (() -> Void)?
    @StateObject private var authenticationViewModel = AuthenticationViewModel()
    @State private var authenticationStatus: Bool = false
    
    var body: some View {
        ZStack {
            if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
                if sharedUserDefaults.bool(forKey: "signedUp") {
                    ZStack {
                        if authenticationStatus {
                            AccountsView(autoFill: autoFill)
                                .environmentObject(credentialProviderViewModel)
                        } else {
                            AuthenticationView()
                                .environmentObject(authenticationViewModel)
                        }
                    }
                    .animation(.easeInOut, value: authenticationStatus)
                } else {
                    NotSignedUpView()
                }
            }
        }
        .onChange(of: authenticationViewModel.authenticated) { authenticatedStatus in
            authenticationStatus = authenticatedStatus
        }
    }
}

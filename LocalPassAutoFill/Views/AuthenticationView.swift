//
//  AuthenticationView.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 24/09/2023.
//

import SwiftUI

struct AuthenticationView: View {
    
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @State private var showIncorrectPasswordAlert: Bool = false
    @FocusState private var textFieldFocused: GlobalHelperDataService.FocusedTextField?
    
    var body: some View {
        VStack {
            titleItem
            passwordFieldItem
            authenticateButtonItem
            
            if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
                if sharedUserDefaults.bool(forKey: "useBiometrics") {
                    authenticateWithBiometricsButtonItem
                }
            }
            
            Spacer()
        }
        .modifier(SignUpViewStyle())
        .alert(isPresented: $showIncorrectPasswordAlert) {
            AuthenticationViewModel.getIncorrectPasswordAlert()
        }
    }
}

// Views
extension AuthenticationView {
    private var titleItem: some View {
        Text("Unlock Vault")
            .font(.largeTitle)
    }
    
    private var passwordFieldItem: some View {
        SecureField("Enter password...", text: Binding(
            get: { authenticationViewModel.password ?? "" },
            set: { authenticationViewModel.password = $0 }
        ))
        .modifier(AuthenticationTextFieldStyle())
        .padding(.top)
        .focused($textFieldFocused, equals: .password)
        .onTapGesture {
            DispatchQueue.main.async {
                textFieldFocused = .password
            }
        }
    }
    
    private var authenticateButtonItem: some View {
        Button {
            if let blob = AccountsDataService.getBlob(),
               let _ = CryptoDataService.decryptBlob(blob: blob, password: authenticationViewModel.password ?? "") {
                AuthenticationViewModel.shared.authenticated = true
                AuthenticationViewModel.shared.password = nil
                authenticationViewModel.authenticated = true
                authenticationViewModel.password = nil
            } else {
                showIncorrectPasswordAlert.toggle()
            }
        } label: {
            Image("AppIconImageRoundedCorners")
                .LogoIconStyle()
        }
    }
    
    private var authenticateWithBiometricsButtonItem: some View {
        Button {
            CryptoDataService.authenticateWithBiometrics { success in
                if success {
                    if let blob = AccountsDataService.getBlob(),
                       let tag = Bundle.main.bundleIdentifier?.components(separatedBy: ".").dropLast().joined(separator: "."),
                       let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass"),
                       let key = CryptoDataService.readKey(tag: tag, iCloudSync: sharedUserDefaults.bool(forKey: "iCloudSync")),
                       let _ = CryptoDataService.decryptBlob(blob: blob, key: key) {
                        AuthenticationViewModel.shared.authenticatedWithBiometrics = true
                        AuthenticationViewModel.shared.authenticated = true
                        authenticationViewModel.authenticatedWithBiometrics = true
                        authenticationViewModel.authenticated = true
                    }
                }
            }
        } label: {
            Image(systemName: "faceid")
                .LogoIconStyle()
        }
    }
}

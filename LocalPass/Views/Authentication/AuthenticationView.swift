//
//  AuthenticationView.swift
//  LocalPass
//
//  Created by Reuben on 10/09/2023.
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
            
            if LocalPassApp.settings.useBiometrics {
                authenticateWithBiometricsButtonItem
            }
            
            Spacer()
        }
        .modifier(SignUpViewStyle())
        .alert(isPresented: $showIncorrectPasswordAlert) {
            AuthenticationViewModel.getIncorrectPasswordAlert()
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var authenticationViewModel = AuthenticationViewModel()
        
        AuthenticationView()
            .environmentObject(authenticationViewModel)
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
                AuthenticationViewModel.rotateKey(authenticationViewModel.password)
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
                       let tag = Bundle.main.bundleIdentifier,
                       let key = CryptoDataService.readKey(tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync),
                       let _ = CryptoDataService.decryptBlob(blob: blob, key: key) {
                        AuthenticationViewModel.shared.authenticatedWithBiometrics = true
                        AuthenticationViewModel.shared.authenticated = true
                        authenticationViewModel.authenticatedWithBiometrics = true
                        authenticationViewModel.authenticated = true
                    }
                }
            }
        } label: {
            Image(systemName: GlobalHelperDataService.getBiometrySymbol())
                .LogoIconStyle()
        }
    }
}

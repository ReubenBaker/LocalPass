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
    @FocusState private var passwordFieldFocused: Bool
    
    var body: some View {
        VStack {
            Text("Unlock Vault")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            SecureField("Enter password...", text: Binding(
                get: { authenticationViewModel.password ?? "" },
                set: { authenticationViewModel.password = $0 }
            ))
            .modifier(AuthenticationTextFieldStyle())
            .padding(.top)
            .focused($passwordFieldFocused)
            .onTapGesture {
                DispatchQueue.main.async {
                    passwordFieldFocused = true
                }
            }
            
            Button {
                if let blob = AccountsDataService.getBlob(),
                   let _ = CryptoDataService.decryptBlob(blob: blob, password: authenticationViewModel.password ?? "") {
                        AuthenticationViewModel.shared.authenticated = true
                        AuthenticationViewModel.shared.password = nil
                        authenticationViewModel.rotateKey()
                        authenticationViewModel.authenticated = true
                        authenticationViewModel.password = nil
                    } else {
                        showIncorrectPasswordAlert.toggle()
                }
            } label: {
                Image("AppIconImageRoundedCorners")
                    .LogoIconStyle()
            }
            
            if LocalPassApp.settings.useBiometrics {
                Button {
                    CryptoDataService.authenticateWithBiometrics { success in
                        if success {
                            if let blob = NotesDataService.getBlob(),
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
                    Image(systemName: "faceid")
                        .LogoIconStyle()
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color("AppThemeColor"))
        .alert(isPresented: $showIncorrectPasswordAlert) {
            authenticationViewModel.getIncorrectPasswordAlert()
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

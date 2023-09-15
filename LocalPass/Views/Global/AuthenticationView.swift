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
    @State private var showBiometricsNotAllowedAlert: Bool = false
    @FocusState private var passwordFieldFocused: Bool
    private var settings = Settings()
    private var cryptoDataService = CryptoDataService()
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Sign In")
                    .font(.largeTitle)
                    .padding()
                
                SecureField("Enter password...", text: Binding(
                    get: { authenticationViewModel.password ?? "" },
                    set: { authenticationViewModel.password = $0 }
                ))
                .frame(maxWidth: .infinity)
                .padding()
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .tint(.primary)
                .background(Color("GeneralColor"))
                .cornerRadius(10)
                .padding()
                .focused($passwordFieldFocused)
                .onTapGesture {
                    DispatchQueue.main.async {
                        passwordFieldFocused = true
                    }
                }
                
                Button {
                    if let blob = AccountsDataService().getBlob() {
                        if let _ = cryptoDataService.decryptBlob(blob: blob, password: authenticationViewModel.password ?? "") {
                            authenticationViewModel.authenticated = true
                            authenticationViewModel.password = nil
                        } else {
                            showIncorrectPasswordAlert.toggle()
                        }
                    }
                } label: {
                    Image("AppIconImageRoundedCorners")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width / 6)
                        .padding()
                }
                
                if settings.useBiometrics {
                    Button {
                        cryptoDataService.authenticateWithBiometrics { success in
                            if success {
                                if let blob = NotesDataService().getBlob() {
                                    if let tag = Bundle.main.bundleIdentifier {
                                        if let key = cryptoDataService.readKeyFromSecureEnclave(tag: tag) {
                                            if let _ = cryptoDataService.decryptBlob(blob: blob, key: key) {
                                                authenticationViewModel.authenticated = true
                                            } else {
                                                showBiometricsNotAllowedAlert.toggle()
                                                settings.biometricsAllowed = false
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "faceid")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width / 6)
                            .opacity(settings.biometricsAllowed ? 1.0 : 0.5)
                    }
                    .disabled(!settings.biometricsAllowed)
                    .onTapGesture {
                        if !settings.biometricsAllowed {
                            showBiometricsNotAllowedAlert.toggle()
                        }
                    }
                }
            }
            .alert(isPresented: $showBiometricsNotAllowedAlert) {
                authenticationViewModel.getBiometricsNotAllowedAlert()
            }
        }
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

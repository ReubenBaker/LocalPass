//
//  SignUpView.swift
//  LocalPass
//
//  Created by Reuben on 10/09/2023.
//

import SwiftUI
import CryptoKit

struct SignUpView: View {
    
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @State private var password: String? = nil
    @FocusState private var passwordFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .padding()
                
                SecureField("Enter password...", text: Binding(
                    get: { password ?? "" },
                    set: { password = $0 }
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
                    if password != nil {
                        signUp()
                    }
                } label: {
                    Image("AppIconImageRoundedCorners")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width / 6)
                        .padding()
                }
            }
        }
        .background(Color("AppThemeColor"))
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var authenticationViewModel = AuthenticationViewModel()
        
        SignUpView()
            .environmentObject(authenticationViewModel)
    }
}

// Functions
extension SignUpView {
    private func signUp() {
        if let tag = Bundle.main.bundleIdentifier {
            if let salt = CryptoDataService.generateRandomSalt() {
                if let password = self.password {
                    if let key = CryptoDataService.deriveKey(password: password, salt: salt) {
                        _ = CryptoDataService.deleteKeyFromSecureEnclave(tag: tag)
                        
                        if CryptoDataService.writeKeyToSecureEnclave(key: key, tag: tag) {
                            if createFiles(key: key, salt: salt) {
                                authenticationViewModel.authenticated = true
                                LocalPassApp.settings.signedUp = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func createFiles(key: SymmetricKey, salt: Data) -> Bool {
        let blob: String = "empty"
        let accountsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localpassaccounts.txt")
        let notesPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localpassnotes.txt")
        
        if let tag = Bundle.main.bundleIdentifier {
            if let key = CryptoDataService.readKeyFromSecureEnclave(tag: tag) {
                if let encryptedBlob = CryptoDataService.encryptBlob(blob: blob, key: key, salt: salt) {
                    do {
                        try encryptedBlob.write(to: accountsPath, options: .atomic)
                        try encryptedBlob.write(to: notesPath, options: .atomic)
                        
                        return true
                    } catch {
                        print("Error creating files: \(error)")
                    }
                }
            }
        }
        
        return false
    }
}

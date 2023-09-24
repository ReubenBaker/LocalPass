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
    @State private var passwordConfirmation: String? = nil
    @State private var showInvalidPasswordAlert: Bool = false
    @State private var showPasswordMismatchAlert: Bool = false
    @FocusState private var passwordFieldFocused: Bool
    @FocusState private var passwordConfirmationFieldFocused: Bool
    
    var body: some View {
        VStack {
            Text("Choose Your Password")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            SecureField("Enter password...", text: Binding(
                get: { password ?? "" },
                set: { password = $0 }
            ))
            .modifier(AuthenticationTextFieldStyle())
            .focused($passwordFieldFocused)
            .onTapGesture {
                DispatchQueue.main.async {
                    passwordFieldFocused = true
                }
            }
            
            SecureField("Confirm password...", text: Binding(
                get: { passwordConfirmation ?? "" },
                set: { passwordConfirmation = $0 }
            ))
            .modifier(AuthenticationTextFieldStyle())
            .focused($passwordConfirmationFieldFocused)
            .onTapGesture {
                DispatchQueue.main.async {
                    passwordConfirmationFieldFocused = true
                }
            }
            
            VStack {
                VStack(alignment: .leading) {
                    if !isValidPassword(password ?? "") {
                        Text("Passwords Requirements:")
                            .foregroundColor(.white)
                        Text("At least 12 Characters")
                            .foregroundColor(password?.count ?? 0 < 12 ? .red : .green)
                        Text("At least 1 Number")
                            .foregroundColor(!(password?.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil) ? .red : .green)
                        Text("At least 1 Special Character")
                            .foregroundColor(!(password?.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_-+=[]{}|;:'\",.<>?/\\~")) != nil) ? .red : .green)
                    } else {
                        Text("Valid Password 🥳")
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(.ultraThickMaterial.opacity(0.5))
                .cornerRadius(10)
                .padding(.bottom)
                
                if isValidPassword(password ?? "") {
                    Label("If you forget your password, your LocalPass data will not be recoverable!", systemImage: "exclamationmark.circle.fill")
                        .foregroundColor(.yellow)
                }
            }
            .animation(.easeInOut, value: password)
            .frame(minHeight: 155)
            .alert(isPresented: $showInvalidPasswordAlert) {
                getInvalidPasswordAlert()
            }
            
            Button {
                if isValidPassword(password ?? "") {
                    if password == passwordConfirmation {
                        signUp()
                    } else {
                        showPasswordMismatchAlert.toggle()
                    }
                } else {
                    showInvalidPasswordAlert.toggle()
                }
            } label: {
                Image("AppIconImageRoundedCorners")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width / 6)
                    .padding()
            }
            .alert(isPresented: $showPasswordMismatchAlert) {
                getPasswordMismatchAlert()
            }
            
            Spacer()
        }
        .padding()
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
                        self.password = nil
                        self.passwordConfirmation = nil
                        
                        if CryptoDataService.deleteKey(tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync) {
                            if CryptoDataService.setkey(key: key, tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync) {
                                if createFiles(key: key, salt: salt) {
                                    AuthenticationViewModel.shared.authenticated = true
                                    authenticationViewModel.authenticated = true
                                    LocalPassApp.settings.signedUp = true
                                }
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
            if let key = CryptoDataService.readKey(tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync) {
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
    
    private func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[0-9])(?=.*[!@#\\$%^&*()_\\-+=\\[\\]{}|;:'\",.<>?/\\\\~]).{12,}$"
        
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func getInvalidPasswordAlert() -> Alert {
        let title = Text("Password is invalid!")
        let message = Text("Please try again")
        let dismissButton: Alert.Button = .default(Text("😢"))
        
        return Alert(
            title: title,
            message: message,
            dismissButton: dismissButton
        )
    }
    
    private func getPasswordMismatchAlert() -> Alert {
        let title = Text("Passwords do not match!")
        let message = Text("Please try again")
        let dismissButton: Alert.Button = .default(Text("😢"))
        
        return Alert(
            title: title,
            message: message,
            dismissButton: dismissButton
        )
    }
}

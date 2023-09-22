//
//  SignUpReturningView.swift
//  LocalPass
//
//  Created by Reuben on 22/09/2023.
//

import SwiftUI

struct SignUpReturningView: View {
    
    @EnvironmentObject private var authenticationViewModel: AuthenticationViewModel
    @State private var password: String? = nil
    @State private var showInvalidPasswordAlert: Bool = false
    @FocusState private var passwordFieldFocused: Bool
    
    var body: some View {
        VStack {
            Text("Already Use LocalPass?")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            VStack(alignment: .leading) {
                Label("Make sure iCloud sync is enabled on your other devices!", systemImage: "exclamationmark.circle.fill")
                    .foregroundColor(.yellow)
                
                Label("Make sure all of your devices are signed into the same iCloud account!", systemImage: "exclamationmark.circle.fill")
                    .foregroundColor(.yellow)
                
                Label("Make sure you enter the same password used for LocalPass on your other devices!", systemImage: "exclamationmark.circle.fill")
                    .foregroundColor(.yellow)
            }
            .padding(.vertical)
            
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
            
            Button {
                LocalPassApp.settings.iCloudSync = true
                
                if retrieveiCloudData() {
                    AuthenticationViewModel.shared.authenticated = true
                    authenticationViewModel.authenticated = true
                    LocalPassApp.settings.signedUp = true
                } else {
                    showInvalidPasswordAlert.toggle()
                    LocalPassApp.settings.iCloudSync = false
                }
            } label: {
                Image("AppIconImageRoundedCorners")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width / 6)
                    .padding()
            }
            .alert(isPresented: $showInvalidPasswordAlert) {
                getInvalidPasswordAlert()
            }
            
            Spacer()
        }
        .padding()
        .background(Color("AppThemeColor"))
    }
}

struct SignUpReturningView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpReturningView()
    }
}

// Functions
extension SignUpReturningView {
    private func retrieveiCloudData() -> Bool {
        if let password = self.password {
            if let blob = AccountsDataService.getBlob() {
                if let _ = CryptoDataService.decryptBlob(blob: blob, password: password) {
                    return true
                }
            }
        }
        
        return false
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
}

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
    @FocusState private var textFieldFocused: GlobalHelperDataService.FocusedTextField?
    
    var body: some View {
        VStack {
            titleItem
            passwordFieldsItem
            passwordRequirementsItem
            signUpButtonItem
            Spacer()
        }
        .modifier(SignUpViewStyle())
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var authenticationViewModel = AuthenticationViewModel()
        
        SignUpView()
            .environmentObject(authenticationViewModel)
    }
}

// Views
extension SignUpView {
    private var titleItem: some View {
        Text("Choose Vault Password")
            .font(.largeTitle)
    }
    
    private var passwordFieldsItem: some View {
        VStack {
            SecureField("Enter password...", text: Binding(
                get: { password ?? "" },
                set: { password = $0 }
            ))
            .modifier(AuthenticationTextFieldStyle())
            .focused($textFieldFocused, equals: .password)
            .onTapGesture {
                DispatchQueue.main.async {
                    textFieldFocused = .password
                }
            }
            
            SecureField("Confirm password...", text: Binding(
                get: { passwordConfirmation ?? "" },
                set: { passwordConfirmation = $0 }
            ))
            .modifier(AuthenticationTextFieldStyle())
            .focused($textFieldFocused, equals: .passwordConfirmation)
            .onTapGesture {
                DispatchQueue.main.async {
                    textFieldFocused = .passwordConfirmation
                }
            }
        }
    }
    
    private var passwordRequirementsItem: some View {
        VStack {
            VStack(alignment: .leading) {
                if !SignUpViewModel.isValidPassword(password) {
                    Text("Passwords Requirements:")
                    Text("At least 12 Characters")
                        .foregroundColor(password?.count ?? 0 < 12 ? .red : .green)
                    Text("At least 1 Number")
                        .foregroundColor(!(password?.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil) ? .red : .green)
                    Text("At least 1 Special Character")
                        .foregroundColor(!(password?.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_-+=[]{}|;:'\",.<>?/\\~")) != nil) ? .red : .green)
                } else {
                    Text("Valid Password 🥳")
                }
            }
            .padding()
            .background(.ultraThickMaterial.opacity(0.5))
            .cornerRadius(10)
            .padding(.bottom)
            
            if SignUpViewModel.isValidPassword(password) {
                Label("If you forget your vault password, your LocalPass data will not be recoverable!", systemImage: "exclamationmark.circle.fill")
                    .foregroundColor(.yellow)
            }
        }
        .animation(.easeInOut, value: password)
        .frame(minHeight: 155)
        .alert(isPresented: $showInvalidPasswordAlert) {
            SignUpViewModel.getInvalidPasswordAlert()
        }
    }
    
    private var signUpButtonItem: some View {
        Button {
            if SignUpViewModel.isValidPassword(password) {
                if password == passwordConfirmation {
                    SignUpViewModel.signUp(password: password, authenticationViewModel)
                } else {
                    showPasswordMismatchAlert.toggle()
                }
            } else {
                showInvalidPasswordAlert.toggle()
            }
        } label: {
            Image("AppIconImageRoundedCorners")
                .LogoIconStyle()
        }
        .alert(isPresented: $showPasswordMismatchAlert) {
            SignUpViewModel.getPasswordMismatchAlert()
        }
    }
}

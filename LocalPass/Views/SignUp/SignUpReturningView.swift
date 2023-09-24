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
    @FocusState private var textFieldFocused: GlobalHelperDataService.FocusedTextField?
    
    var body: some View {
        VStack {
            titleItem
            warningLabelsItem
            passwordFieldItem
            authenticateButtonItem
            Spacer()
        }
        .modifier(SignUpViewStyle())
    }
}

struct SignUpReturningView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var authenticationViewModel = AuthenticationViewModel()
        
        SignUpReturningView()
            .environmentObject(authenticationViewModel)
    }
}

// Views
extension SignUpReturningView {
    private var titleItem: some View {
        Text("Already Use LocalPass?")
            .font(.largeTitle)
    }
    
    private var warningLabelsItem: some View {
        VStack(alignment: .leading) {
            Label("Make sure iCloud sync is enabled on your other devices!", systemImage: "exclamationmark.circle.fill")
                .foregroundColor(.yellow)
            
            Label("Make sure all of your devices are signed into the same iCloud account!", systemImage: "exclamationmark.circle.fill")
                .foregroundColor(.yellow)
            
            Label("Make sure you enter the same password used for LocalPass on your other devices!", systemImage: "exclamationmark.circle.fill")
                .foregroundColor(.yellow)
            
            Label("iCloud sync is currently in beta and may produce unexpected results!", systemImage: "exclamationmark.circle.fill")
                .foregroundColor(.yellow)
        }
        .padding(.vertical)
    }
    
    private var passwordFieldItem: some View {
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
    }
    
    private var authenticateButtonItem: some View {
        Button {
            LocalPassApp.settings.iCloudSync = true
            
            if SignUpViewModel.retrieveiCloudData(password) {
                AuthenticationViewModel.shared.authenticated = true
                authenticationViewModel.authenticated = true
                LocalPassApp.settings.signedUp = true
            } else {
                showInvalidPasswordAlert.toggle()
                LocalPassApp.settings.iCloudSync = false
            }
        } label: {
            Image("AppIconImageRoundedCorners")
                .LogoIconStyle()
        }
        .alert(isPresented: $showInvalidPasswordAlert) {
            SignUpViewModel.getInvalidPasswordAlert()
        }
    }
}

//
//  AddAccountView.swift
//  LocalPass
//
//  Created by Reuben on 23/08/2023.
//

import SwiftUI

struct AddAccountView: View {
    
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newName: String = ""
    @State private var newUsername: String = ""
    @State private var newPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var urlField: Bool = false
    @State private var newUrl: String = ""
    @State private var accountSuccess: Bool = false
    @State private var showAccountSuccessAlert: Bool = false
    @FocusState private var nameTextFieldFocused: Bool
    @FocusState private var usernameTextFieldFocused: Bool
    @FocusState private var passwordTextFieldFocused: Bool
    @FocusState private var urlTextFieldFocused: Bool
    
    var body: some View {
        ScrollView {
            VStack {
                Text(newName != "" ? newName : "New Account")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                nameItem
                usernameItem
                passwordItem
                urlItem
                addItem
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .background(.ultraThinMaterial)
        .overlay(closeButton, alignment: .bottom)
        .alert(isPresented: $showAccountSuccessAlert) {
            getAccountSuccessAlert(accountSuccess: accountSuccess)
        }
    }
}

struct AddAccountView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        
        AddAccountView()
            .environmentObject(accountsViewModel)
    }
}

// Functions
extension AddAccountView {
    func getAccountSuccessAlert(accountSuccess: Bool) -> Alert {
        var title: Text = Text("")
        
        if accountSuccess {
            title = Text("Account successfully created!")
        } else {
            title = Text("Account could not be created!")
        }
        
        let dismissButton: Alert.Button = .default(accountSuccess ? Text("🥳") : Text("😢"), action: {
            if accountSuccess {
                dismiss()
            }
        })
        

        return Alert(
            title: title,
            message: nil,
            dismissButton: dismissButton
        )
    }
}

// Views
extension AddAccountView {
    private var nameItem: some View {
        HStack {
            Image(systemName: "tag.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(.vertical, 10)
                .foregroundColor(Color("AccentColor"))
            
            TextField("Enter account name...", text: $newName)
                .frame(maxHeight: .infinity)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .tint(.primary)
                .focused($nameTextFieldFocused)
                .onTapGesture {
                    DispatchQueue.main.async {
                        nameTextFieldFocused = true
                    }
                }
                
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .frame(height: accountsViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var usernameItem: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(.vertical, 10)
                .foregroundColor(Color("AccentColor"))
            
            TextField("Enter username...", text: $newUsername)
                .frame(maxHeight: .infinity)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .tint(.primary)
                .focused($usernameTextFieldFocused)
                .onTapGesture {
                    DispatchQueue.main.async {
                        usernameTextFieldFocused = true
                    }
                }
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .frame(height: accountsViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var passwordItem: some View {
        HStack {
            Image(systemName: "lock.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(.vertical, 10)
                .foregroundColor(Color("AccentColor"))
            
            if showPassword {
                TextField("Enter password...", text: $newPassword)
                    .frame(maxHeight: .infinity)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .tint(.primary)
                    .focused($passwordTextFieldFocused)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            passwordTextFieldFocused = true
                        }
                    }
            } else {
                SecureField("Enter password...", text: $newPassword)
                    .frame(maxHeight: .infinity)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .tint(.primary)
                    .focused($passwordTextFieldFocused)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            passwordTextFieldFocused = true
                        }
                    }
            }
            
            Spacer()
            
            Button {
                let isFocused = passwordTextFieldFocused
                
                showPassword.toggle()
                
                if isFocused {
                    DispatchQueue.main.async {
                        passwordTextFieldFocused = true
                    }
                }
            } label: {
                Image(systemName: showPassword ? "eye.slash.circle.fill" : "eye.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 10)
                    .foregroundColor(Color("AccentColor"))
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .frame(height: accountsViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var urlItem: some View {
        Button {
            withAnimation() {
                urlField = true
            }
        } label: {
            if urlField {
                HStack() {
                    Image(systemName: "link.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(.vertical, 10)
                        .foregroundColor(Color("AccentColor"))
                    
                    TextField("Enter url...", text: $newUrl)
                        .frame(maxHeight: .infinity)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .tint(.primary)
                        .focused($urlTextFieldFocused)
                        .onAppear {
                            DispatchQueue.main.async {
                                urlTextFieldFocused = true
                            }
                        }
                    
                    Button {
                        withAnimation() {
                            urlField = false
                            newUrl = ""
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            } else {
                Text("Add URL")
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .frame(height: accountsViewModel.viewItemHeight)
        .frame(maxWidth: urlField ? .infinity : nil)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var addItem: some View {
        Button {
            accountSuccess = accountsViewModel.addAccount(
                name: newName,
                username: newUsername,
                password: newPassword,
                url: newUrl != "" ? newUrl : nil
            )
            
            showAccountSuccessAlert.toggle()
       } label: {
           Text("Add Account")
               .font(.headline)
               .padding()
               .foregroundColor(.primary)
               .background(.cyan)
               .cornerRadius(10)
               .shadow(radius: 4)
               .padding()
       }
    }
    
    private var closeButton: some View {
        Button {
           dismiss()
       } label: {
           Image(systemName: "xmark")
               .font(.headline)
               .padding()
               .foregroundColor(Color("AccentColor"))
               .background(.thickMaterial)
               .cornerRadius(10)
               .shadow(radius: 4)
               .padding()
       }
    }
}

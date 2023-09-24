//
//  AddAccountView.swift
//  LocalPass
//
//  Created by Reuben on 23/08/2023.
//

import SwiftUI

struct AddAccountView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @State private var newName: String = ""
    @State private var newUsername: String = ""
    @State private var newPassword: String = ""
    @State private var newUrl: String = ""
    @State private var newOtpSecret: String = ""
    @State private var showPassword: Bool = false
    @State private var urlFieldClicked: Bool = false
    @State private var TOTPFieldClicked: Bool = false
    @State private var accountSuccess: Bool = false
    @State private var showAccountSuccessAlert: Bool = false
    @State private var showPasswordGeneratorSheet: Bool = false
    @FocusState private var focusedTextField: GlobalHelperDataService.FocusedTextField?
    
    var body: some View {
        VStack {
            titleItem
            nameItem
            usernameItem
            passwordItem
            urlItem
            otpItem
            addItem
            Spacer()
            CloseButtonView()
        }
        .padding()
        .background(.ultraThinMaterial)
        .alert(isPresented: $showAccountSuccessAlert) {
            getAccountSuccessAlert(accountSuccess: accountSuccess)
        }
        .sheet(isPresented: $showPasswordGeneratorSheet) {
            PasswordGeneratorView(password: $newPassword)
                .presentationDetents([.fraction(0.5)])
        }
    }
}

// Preview
struct AddAccountView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        
        AddAccountView()
            .environmentObject(accountsViewModel)
    }
}

// Functions
extension AddAccountView {
    private func getAccountSuccessAlert(accountSuccess: Bool) -> Alert {
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
    private var titleItem: some View {
        Text(newName != "" ? newName : "New Account")
            .modifier(TitleTextStyle())
    }
    
    private var nameItem: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .ListItemImageStyle()
            
            TextField("Enter account name...", text: $newName)
                .modifier(ListItemTextFieldStyle())
                .focused($focusedTextField, equals: .name)
                .onTapGesture {
                    DispatchQueue.main.async {
                        focusedTextField = .name
                    }
                }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var usernameItem: some View {
        HStack {
            Image(systemName: "at.circle.fill")
                .ListItemImageStyle()
            
            TextField("Enter username...", text: $newUsername)
                .modifier(RawTextFieldInputStyle())
                .modifier(ListItemTextFieldStyle())
                .focused($focusedTextField, equals: .username)
                .onTapGesture {
                    DispatchQueue.main.async {
                        focusedTextField = .username
                    }
                }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var passwordItem: some View {
        HStack {
            Image(systemName: "lock.circle.fill")
                .ListItemImageStyle()
            
            if showPassword {
                TextField("Enter password...", text: $newPassword)
                    .modifier(RawTextFieldInputStyle())
                    .modifier(ListItemTextFieldStyle())
                    .focused($focusedTextField, equals: .password)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            focusedTextField = .password
                        }
                    }
            } else {
                SecureField("Enter password...", text: $newPassword)
                    .modifier(RawTextFieldInputStyle())
                    .modifier(ListItemTextFieldStyle())
                    .focused($focusedTextField, equals: .password)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            focusedTextField = .password
                        }
                    }
            }
            
            Spacer()
            
            Button {
                showPasswordGeneratorSheet.toggle()
            } label: {
                Image(systemName: "gear.circle.fill")
                    .ListItemImageStyle()
            }
            
            Button {
                showPassword.toggle()
            } label: {
                Image(systemName: showPassword ? "eye.slash.circle.fill" : "eye.circle.fill")
                    .ListItemImageStyle()
            }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var urlItem: some View {
        Button {
            withAnimation() {
                urlFieldClicked = true
            }
        } label: {
            if urlFieldClicked {
                HStack() {
                    Image(systemName: "link.circle.fill")
                        .ListItemImageStyle()
                    
                    TextField("Enter url...", text: $newUrl)
                        .modifier(RawTextFieldInputStyle())
                        .modifier(ListItemTextFieldStyle())
                        .focused($focusedTextField, equals: .url)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                focusedTextField = .url
                            }
                        }
                    
                    Button {
                        withAnimation() {
                            urlFieldClicked = false
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
        .modifier(AccountDetailViewItemStyle(fieldClicked: urlFieldClicked))
    }
    
    private var otpItem: some View {
        Button {
            withAnimation() {
                TOTPFieldClicked = true
            }
        } label: {
            if TOTPFieldClicked {
                HStack() {
                    Image(systemName: "repeat.circle.fill")
                        .ListItemImageStyle()
                    
                    TextField("Enter TOTP key...", text: $newOtpSecret)
                        .modifier(RawTextFieldInputStyle())
                        .modifier(ListItemTextFieldStyle())
                        .focused($focusedTextField, equals: .otpSecret)
                        .onTapGesture {
                            DispatchQueue.main.async {
                                focusedTextField = .otpSecret
                            }
                        }
                    
                    Button {
                        withAnimation() {
                            TOTPFieldClicked = false
                            newOtpSecret = ""
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("AccentColor"))
                    }
                }
            } else {
                Text("Setup TOTP")
            }
        }
        .modifier(AccountDetailViewItemStyle(fieldClicked: TOTPFieldClicked))
    }
    
    private var addItem: some View {
        Button {
            accountSuccess = accountsViewModel.addAccount(
                name: newName,
                username: newUsername,
                password: newPassword,
                url: newUrl != "" ? newUrl : nil,
                otpSecret: newOtpSecret != "" ? newOtpSecret : nil
            )
            
            showAccountSuccessAlert.toggle()
       } label: {
           Text("Add Account")
       }
       .buttonStyle(ProminentButtonStyle(.cyan))
    }
}

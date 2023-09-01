//
//  AccountDetailView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @EnvironmentObject private var copyPopupOverlayViewModel: CopyPopupOverlayViewModel
    @Binding var account: Account
    @State private var newUsername: String = ""
    @State private var newPassword: String = ""
    @State private var newUrl: String = ""
    @State private var newOtpSecret: String = ""
    @State private var otpValue: String = ""
    @State private var otpTimeLeft: Int = 0
    @State private var showDeleteAlert: Bool = false
    @State private var showPassword: Bool = false
    @State private var urlField: Bool = false
    @State private var otpSecretField: Bool = false
    @State private var showPasswordGeneratorSheet: Bool = false
    @FocusState private var nameTextFieldFocused: Bool
    @FocusState private var usernameTextFieldFocused: Bool
    @FocusState private var passwordTextFieldFocused: Bool
    @FocusState private var urlTextFieldFocused: Bool
    @FocusState private var otpSecretTextFieldFocused: Bool
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    var body: some View {
        ScrollView {
            VStack {
                titleItem

                if editMode?.wrappedValue != .active {
                    usernameItem
                    passwordItem
                    
                    if account.url != nil && account.otpSecret != nil {
                        urlItem
                        otpItem
                    } else if account.url != nil && account.otpSecret == nil {
                        urlItem
                        noOtpItem
                    } else if account.url == nil && account.otpSecret != nil {
                        otpItem
                        noUrlItem
                    } else {
                        noUrlItem
                        noOtpItem
                    }
                } else {
                    editUsernameItem
                    editPasswordItem
                    editUrlItem
                    editOtpItem
                }
                
                creationDateTimeItem()
                updatedDateTimeItem()
                deleteItem
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .background(.ultraThinMaterial)
        .overlay(closeButton, alignment: .bottom)
        .overlay(alignment: .top) {
            CopyPopupOverlayView()
        }
        .overlay{
            PrivacyOverlayView()
        }
        .alert(isPresented: $showDeleteAlert) {
            accountsViewModel.getDeleteAlert()
        }
        .sheet(isPresented: $showPasswordGeneratorSheet) {
            PasswordGeneratorView(password: $newPassword)
                .presentationDetents([.fraction(0.45)])
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .onChange(of: editMode?.wrappedValue) { editMode in
            if editMode == .inactive {
                if newUsername != "" {
                    let updatedAccount = Account(name: account.name, username: newUsername, password: account.password, url: account.url, creationDateTime: account.creationDateTime, updatedDateTime: Date(), starred: account.starred, otpSecret: account.otpSecret)
                    
                    accountsViewModel.updateAccount(id: account.id, account: updatedAccount)
                }
                
                if newPassword != "" {
                    let updatedAccount = Account(name: account.name, username: account.username, password: newPassword, url: account.url, creationDateTime: account.creationDateTime, updatedDateTime: Date(), starred: account.starred, otpSecret: account.otpSecret)
                    
                    accountsViewModel.updateAccount(id: account.id, account: updatedAccount)
                }
                
                if newUrl != "" {
                    let updatedAccount = Account(name: account.name, username: account.username, password: account.password, url: newUrl, creationDateTime: account.creationDateTime, updatedDateTime: Date(), starred: account.starred, otpSecret: account.otpSecret)
                    
                    accountsViewModel.updateAccount(id: account.id, account: updatedAccount)
                }
            }
        }
        .onDisappear {
            accountsViewModel.updateAccount(id: account.id, account: account)
        }
    }
}

// Preview
struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var accountsViewModel = AccountsViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        @State var account = Account(name: "default", username: "default", password: "default")
        
        AccountDetailView(account: $account)
            .environmentObject(mainViewModel)
            .environmentObject(accountsViewModel)
            .environmentObject(copyPopupOverlayViewModel)
            .environmentObject(privacyOverlayViewModel)
    }
}

// Functions
extension AccountDetailView {
    private func updateTimeLeft() {
        let timeSince1970 = Int(Date().timeIntervalSince1970)
        let nextInterval = (timeSince1970 / 30) * 30
        otpTimeLeft = 30 - abs(nextInterval - timeSince1970)
    }
    
    private func startTOTPTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            updateTimeLeft()
            
            if otpTimeLeft == 30 {
                if let secret = account.otpSecret {
                    otpValue = TOTPGeneratorDataService().TOTP(secret: secret)
                }
            }
        }
    }
}

// Views
extension AccountDetailView {
    private var titleItem: some View {
        ZStack {
            Text(account.name)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(2)
                .padding(.horizontal, 70)
            
            HStack {
                EditButton()
                Spacer()
            }
            .padding(.horizontal)
        }
        .padding(.top, copyPopupOverlayViewModel.showCopyPopupOverlay ? 30 : 0)
    }
    
    private var usernameItem: some View {
        Button {
            mainViewModel.copyToClipboard(text: account.username)
            copyPopupOverlayViewModel.displayCopyPopupOverlay()
        } label: {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("AccentColor"))
                
                Text(account.username)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .frame(height: mainViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var editUsernameItem: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(.vertical, 10)
                .foregroundColor(Color("AccentColor"))
            
            TextField("\(account.username)", text: $newUsername)
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
        .frame(height: mainViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var passwordItem: some View {
        Button {
            mainViewModel.copyToClipboard(text: account.password)
            copyPopupOverlayViewModel.displayCopyPopupOverlay()
        } label: {
            HStack {
                Image(systemName: "lock.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("AccentColor"))
                
                Text(showPassword ? account.password : "************")
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.circle.fill" : "eye.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .frame(height: mainViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var editPasswordItem: some View {
        HStack {
            Image(systemName: "lock.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(.vertical, 10)
                .foregroundColor(Color("AccentColor"))
            
            if showPassword {
                TextField("\(account.password)", text: $newPassword)
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
                SecureField("************", text: $newPassword)
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
                showPasswordGeneratorSheet.toggle()
            } label: {
                ZStack {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(.vertical, 10)
                        .foregroundColor(Color("AccentColor"))
                    
                    Image(systemName: "key.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(.vertical, 15)
                        .foregroundColor(Color("GeneralColor"))
                }
            }
            
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
        .frame(height: mainViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var urlItem: some View {
        Button {
            mainViewModel.copyToClipboard(text: account.url ?? "")
            copyPopupOverlayViewModel.displayCopyPopupOverlay()
        } label: {
            HStack {
                Image(systemName: "link.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("AccentColor"))
                
                Text(account.url ?? "")
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .frame(height: mainViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var noUrlItem: some View {
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
                        .onSubmit {
                            let updatedAccount = Account(name: account.name, username: account.username, password: account.password, url: newUrl, creationDateTime: account.creationDateTime, updatedDateTime: Date(), starred: account.starred, otpSecret: account.otpSecret)
                            
                            accountsViewModel.updateAccount(id: account.id, account: updatedAccount)
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
        .frame(height: mainViewModel.viewItemHeight)
        .frame(minWidth: 150, maxWidth: urlField ? .infinity : nil)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var editUrlItem: some View {
        HStack {
            Image(systemName: "link.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(.vertical, 10)
                .foregroundColor(Color("AccentColor"))
            
            TextField("\(account.url ?? "Enter url...")", text: $newUrl)
                .frame(maxHeight: .infinity)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .tint(.primary)
                .focused($urlTextFieldFocused)
                .onTapGesture {
                    DispatchQueue.main.async {
                        urlTextFieldFocused = true
                    }
                }
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .frame(height: mainViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var otpItem: some View {
        Button {
            mainViewModel.copyToClipboard(text: otpValue)
            copyPopupOverlayViewModel.displayCopyPopupOverlay()
        } label: {
            HStack {
                Image(systemName: "repeat.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("AccentColor"))
                
                Text(otpValue)
                    .fontWeight(.semibold)
                    .onAppear {
                        updateTimeLeft()
                        startTOTPTimer()
                        
                        if let secret = account.otpSecret {
                            otpValue = TOTPGeneratorDataService().TOTP(secret: secret)
                        }
                    }
                
                Text("\(otpTimeLeft)")
                
                Spacer()
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .frame(height: mainViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var noOtpItem: some View {
        Button {
            withAnimation() {
                otpSecretField = true
            }
        } label: {
            if otpSecretField {
                HStack() {
                    Image(systemName: "repeat.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(.vertical, 10)
                        .foregroundColor(Color("AccentColor"))
                    
                    TextField("Enter TOTP key...", text: $newOtpSecret)
                        .frame(maxHeight: .infinity)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .tint(.primary)
                        .focused($otpSecretTextFieldFocused)
                        .onAppear {
                            DispatchQueue.main.async {
                                otpSecretTextFieldFocused = true
                            }
                        }
                        .onSubmit {
                            let updatedAccount = Account(name: account.name, username: account.username, password: account.password, url: account.url, creationDateTime: account.creationDateTime, updatedDateTime: Date(), starred: account.starred, otpSecret: newOtpSecret)
                            
                            accountsViewModel.updateAccount(id: account.id, account: updatedAccount)
                        }
                    
                    Button {
                        withAnimation() {
                            otpSecretField = false
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
        .foregroundColor(.primary)
        .padding(.horizontal)
        .frame(height: mainViewModel.viewItemHeight)
        .frame(minWidth: 150, maxWidth: otpSecretField ? .infinity : nil)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var editOtpItem: some View {
        HStack {
            Image(systemName: "repeat.circle.fill")
                .resizable()
                .scaledToFit()
                .padding(.vertical, 10)
                .foregroundColor(Color("AccentColor"))
            
            TextField("\(account.otpSecret ?? "Enter TOTP key...")", text: $newOtpSecret)
                .frame(maxHeight: .infinity)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
                .tint(.primary)
                .focused($otpSecretTextFieldFocused)
                .onTapGesture {
                    DispatchQueue.main.async {
                        otpSecretTextFieldFocused = true
                    }
                }
        }
        .foregroundColor(.primary)
        .padding(.horizontal)
        .frame(height: mainViewModel.viewItemHeight)
        .frame(maxWidth: .infinity)
        .background(Color("GeneralColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func creationDateTimeItem() -> some View {
        let createdText = Text("\(dateFormatter.string(from: account.creationDateTime))")
        
        return Text("Time Created: \(createdText)")
    }
    
    private func updatedDateTimeItem() -> some View {
        var lastUpdatedText = Text("Never")

        if let lastUpdated = account.updatedDateTime {
            lastUpdatedText = Text("\(dateFormatter.string(from: lastUpdated))")
        }
        
        return Text("Last Updated: \(lastUpdatedText)")
    }
    
    private var deleteItem: some View {
        Button {
            accountsViewModel.accountToDelete = account
            showDeleteAlert.toggle()
       } label: {
           Text("Delete")
               .font(.headline)
               .padding()
               .foregroundColor(.primary)
               .background(.red)
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

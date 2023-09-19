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
    @State private var currentOtpSecret: String? = nil
    @State private var otpValue: String = ""
    @State private var otpTimeLeft: Int = 0
    @State private var showDeleteAlert: Bool = false
    @State private var showPassword: Bool = false
    @State private var addUrlFieldClicked: Bool = false
    @State private var addTOTPFieldClicked: Bool = false
    @State private var showPasswordGeneratorSheet: Bool = false
    @FocusState private var focusedTextField: GlobalHelperDataService.FocusedTextField?
    
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
                
                creationDateTimeItem
                updatedDateTimeItem
                deleteItem
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .padding(.horizontal)
        .background(.ultraThinMaterial)
        .overlay(CloseButtonView(), alignment: .bottom)
        .overlay(alignment: .top) {
            CopyPopupOverlayView()
        }
        .alert(isPresented: $showDeleteAlert) {
            accountsViewModel.getDeleteAlert()
        }
        .sheet(isPresented: $showPasswordGeneratorSheet) {
            PasswordGeneratorView(password: $newPassword)
                .presentationDetents([.fraction(0.45)])
                .overlay(PrivacyOverlayView())
        }
        .onChange(of: editMode?.wrappedValue) { mode in
            if mode != .active {
                if newUsername != "" || newPassword != "" || newUrl != "" || newOtpSecret != "" {
                    let updatedAccount = Account(
                        name: account.name,
                        username: newUsername != "" ? newUsername : account.username,
                        password: newPassword != "" ? newPassword : account.password,
                        url: newUrl != "" ? newUrl : account.url,
                        creationDateTime: account.creationDateTime,
                        updatedDateTime: Date(),
                        starred: account.starred,
                        otpSecret: newOtpSecret != "" ? newOtpSecret : account.otpSecret,
                        id: account.id
                    )
                    
                    accountsViewModel.updateAccount(id: account.id, account: updatedAccount)
                    
                    (newUsername, newPassword, newUrl, newOtpSecret) = ("", "", "", "")
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
        @State var account = Account(name: "default", username: "default", password: "default")
        
        AccountDetailView(account: $account)
            .environmentObject(mainViewModel)
            .environmentObject(accountsViewModel)
            .environmentObject(copyPopupOverlayViewModel)
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
                generateTOTP()
            }
        }
    }
    
    private func generateTOTP() {
        if let secret = currentOtpSecret {
            otpValue = TOTPGeneratorDataService.TOTP(secret: secret)
        }
    }
}

// Views
extension AccountDetailView {
    private var titleItem: some View {
        ZStack {
            Text(account.name)
                .modifier(TitleTextStyle())
            
            HStack {
                EditButton()
                Spacer()
            }
        }
        .padding(.top, copyPopupOverlayViewModel.showCopyPopupOverlay ? 30 : 0)
    }
    
    private var usernameItem: some View {
        Button {
            GlobalHelperDataService.copyToClipboard(text: account.username)
            copyPopupOverlayViewModel.displayCopyPopupOverlay()
        } label: {
            HStack {
                if let url = account.url {
                    if LocalPassApp.settings.showFavicons {
                        FaviconImageView(url: url)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color("AccentColor"))
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color("AccentColor"))
                }
                
                Text(account.username)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.vertical, 10)
        }
        .modifier(AccountDetailViewItemStyle())
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
        Button {
            GlobalHelperDataService.copyToClipboard(text: account.password)
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
            .padding(.vertical, 10)
        }
        .modifier(AccountDetailViewItemStyle())
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
                    .focused($focusedTextField, equals: .password)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            focusedTextField = .password
                        }
                    }
            } else {
                SecureField("************", text: $newPassword)
                    .frame(maxHeight: .infinity)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .tint(.primary)
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
//                let isFocused = textFieldFocused.password
//
//                showPassword.toggle()
//
//                if isFocused {
//                    DispatchQueue.main.async {
//                        textFieldFocused.password = true
//                    }
//                }
            } label: {
                Image(systemName: showPassword ? "eye.slash.circle.fill" : "eye.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(.vertical, 10)
                    .foregroundColor(Color("AccentColor"))
            }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var urlItem: some View {
        Button {
            GlobalHelperDataService.copyToClipboard(text: account.url ?? "")
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
            .padding(.vertical, 10)
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var noUrlItem: some View {
        Button {
            withAnimation() {
                addUrlFieldClicked = true
            }
        } label: {
            if addUrlFieldClicked {
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
                        .focused($focusedTextField, equals: .url)
                        .onAppear {
                            DispatchQueue.main.async {
                                focusedTextField = .url
                            }
                        }
                        .onSubmit {
                            let updatedAccount = Account(
                                name: account.name,
                                username: account.username,
                                password: account.password,
                                url: newUrl,
                                creationDateTime: account.creationDateTime,
                                updatedDateTime: Date(),
                                starred: account.starred,
                                otpSecret: account.otpSecret,
                                id: account.id
                            )
                            
                            accountsViewModel.updateAccount(id: account.id, account: updatedAccount)
                            
                            newUrl = ""
                        }
                    
                    Button {
                        withAnimation() {
                            addUrlFieldClicked = false
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
        .modifier(AccountDetailViewItemStyle(fieldClicked: addUrlFieldClicked))
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
                .focused($focusedTextField, equals: .url)
                .onTapGesture {
                    DispatchQueue.main.async {
                        focusedTextField = .url
                    }
                }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var otpItem: some View {
        Button {
            GlobalHelperDataService.copyToClipboard(text: otpValue)
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
                            currentOtpSecret = secret
                            generateTOTP()
                        }
                    }
                    .onChange(of: account.otpSecret ?? "") { newSecret in
                        currentOtpSecret = newSecret
                        generateTOTP()
                    }
                
                Text("\(otpTimeLeft)")
                
                Spacer()
            }
            .padding(.vertical, 10)
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var noOtpItem: some View {
        Button {
            withAnimation() {
                addTOTPFieldClicked = true
            }
        } label: {
            if addTOTPFieldClicked {
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
                        .focused($focusedTextField, equals: .otpSecret)
                        .onAppear {
                            DispatchQueue.main.async {
                                focusedTextField = .otpSecret
                            }
                        }
                        .onSubmit {
                            let updatedAccount = Account(
                                name: account.name,
                                username: account.username,
                                password: account.password,
                                url: account.url,
                                creationDateTime: account.creationDateTime,
                                updatedDateTime: Date(),
                                starred: account.starred,
                                otpSecret: newOtpSecret,
                                id: account.id
                            )
                            
                            accountsViewModel.updateAccount(id: account.id, account: updatedAccount)
                            
                            newOtpSecret = ""
                        }
                    
                    Button {
                        withAnimation() {
                            addTOTPFieldClicked = false
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
        .modifier(AccountDetailViewItemStyle(fieldClicked: addTOTPFieldClicked))
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
                .focused($focusedTextField, equals: .otpSecret)
                .onTapGesture {
                    DispatchQueue.main.async {
                        focusedTextField = .otpSecret
                    }
                }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var creationDateTimeItem: some View {
        ZStack {
            let createdText = Text("\(GlobalHelperDataService.dateFormatter.string(from: account.creationDateTime))")
            
            return Text("Time Created: \(createdText)")
        }
    }
    
    private var updatedDateTimeItem: some View {
        ZStack {
            var lastUpdatedText = Text("Never")

            if let lastUpdated = account.updatedDateTime {
                lastUpdatedText = Text("\(GlobalHelperDataService.dateFormatter.string(from: lastUpdated))")
            }
            
            return Text("Last Updated: \(lastUpdatedText)")
        }
    }
    
    private var deleteItem: some View {
        Button("Delete") {
            accountsViewModel.accountToDelete = account
            showDeleteAlert.toggle()
       }
        .buttonStyle(DeleteButtonStyle())
    }
}

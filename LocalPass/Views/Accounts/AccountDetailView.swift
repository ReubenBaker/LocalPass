//
//  AccountDetailView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountDetailView: View {
    
    @Environment(\.editMode) private var editMode
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
    @State private var otpColor: Color = .green
    @State private var otpFlashing: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showPassword: Bool = false
    @State private var addUrlFieldClicked: Bool = false
    @State private var addTOTPFieldClicked: Bool = false
    @State private var showPasswordGeneratorSheet: Bool = false
    @FocusState private var focusedTextField: GlobalHelperDataService.FocusedTextField?
    
    var body: some View {
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
            
            VStack(alignment: .leading) {
                creationDateTimeItem
                updatedDateTimeItem
            }
            
            deleteItem
            Spacer()
            CloseButtonView()
        }
        .padding()
        .background(.ultraThinMaterial)
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
        @StateObject var accountsViewModel = AccountsViewModel()
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        @State var account = Account(name: "default", username: "default", password: "default", url: "default", otpSecret: "TESTKEY")
        
        AccountDetailView(account: $account)
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
            otpValue = TOTPGeneratorDataService.TOTP(secret)
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
    }
    
    private var usernameItem: some View {
        Button {
            GlobalHelperDataService.copyToClipboard(account.username)
            copyPopupOverlayViewModel.displayCopyPopupOverlay()
        } label: {
            HStack {
                if let url = account.url {
                    if LocalPassApp.settings.showFavicons {
                        FaviconImageView(url: url)
                    } else {
                        Image(systemName: "at.circle.fill")
                            .ListItemImageStyle()
                    }
                } else {
                    Image(systemName: "at.circle.fill")
                        .ListItemImageStyle()
                }
                
                Text(account.username)
                    .fontWeight(.semibold)
                
                Spacer()
            }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var editUsernameItem: some View {
        HStack {
            Image(systemName: "at.circle.fill")
                .ListItemImageStyle()
            
            TextField("\(account.username)", text: $newUsername)
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
        Button {
            GlobalHelperDataService.copyToClipboard(account.password)
            copyPopupOverlayViewModel.displayCopyPopupOverlay()
        } label: {
            HStack {
                Image(systemName: "lock.circle.fill")
                    .ListItemImageStyle()
                
                Text(showPassword ? account.password : "********")
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.circle.fill" : "eye.circle.fill")
                        .ListItemImageStyle()
                }
            }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var editPasswordItem: some View {
        HStack {
            Image(systemName: "lock.circle.fill")
                .ListItemImageStyle()
            
            if showPassword {
                TextField("\(account.password)", text: $newPassword)
                    .modifier(RawTextFieldInputStyle())
                    .modifier(ListItemTextFieldStyle())
                    .focused($focusedTextField, equals: .password)
                    .onTapGesture {
                        DispatchQueue.main.async {
                            focusedTextField = .password
                        }
                    }
            } else {
                SecureField("********", text: $newPassword)
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
            GlobalHelperDataService.copyToClipboard(account.url ?? "")
            copyPopupOverlayViewModel.displayCopyPopupOverlay()
        } label: {
            HStack {
                Image(systemName: "link.circle.fill")
                    .ListItemImageStyle()
                
                Text(account.url ?? "")
                    .fontWeight(.semibold)
                
                Spacer()
            }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var noUrlItem: some View {
        Button {
            withAnimation() {
                addUrlFieldClicked = true
                focusedTextField = .url
            }
        } label: {
            if addUrlFieldClicked {
                HStack() {
                    Image(systemName: "link.circle.fill")
                        .ListItemImageStyle()
                    
                    TextField("Enter url...", text: $newUrl)
                        .modifier(RawTextFieldInputStyle())
                        .modifier(ListItemTextFieldStyle())
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
                .ListItemImageStyle()
            
            TextField("\(account.url ?? "Enter url...")", text: $newUrl)
                .modifier(RawTextFieldInputStyle())
                .modifier(ListItemTextFieldStyle())
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
            GlobalHelperDataService.copyToClipboard(otpValue)
            copyPopupOverlayViewModel.displayCopyPopupOverlay()
        } label: {
            HStack {
                Image(systemName: "repeat.circle.fill")
                    .ListItemImageStyle()
                
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
                
                Spacer()
                
                ZStack {
                    if !otpFlashing {
                        Circle()
                            .stroke(.gray, lineWidth: 5)
                    }
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(otpTimeLeft - 1) / 30)
                        .stroke(otpColor, lineWidth: 5)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: otpTimeLeft)
                    
                    Text("\(otpTimeLeft)")
                }
                .onChange(of: otpTimeLeft) { newValue in
                    withAnimation(.easeInOut) {
                        if newValue <= 5 {
                            otpColor = .red
                            otpFlashing.toggle()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                otpFlashing.toggle()
                            }
                        } else if newValue <= 10 {
                            otpColor = .yellow
                        } else {
                            otpColor = .green
                        }
                    }
                }
            }
        }
        .modifier(AccountDetailViewItemStyle())
    }
    
    private var noOtpItem: some View {
        Button {
            withAnimation() {
                addTOTPFieldClicked = true
                focusedTextField = .otpSecret
            }
        } label: {
            if addTOTPFieldClicked {
                HStack() {
                    Image(systemName: "repeat.circle.fill")
                        .ListItemImageStyle()
                    
                    TextField("Enter TOTP key...", text: $newOtpSecret)
                        .modifier(RawTextFieldInputStyle())
                        .modifier(ListItemTextFieldStyle())
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
                .ListItemImageStyle()
            
            TextField("\(account.otpSecret ?? "Enter TOTP key...")", text: $newOtpSecret)
                .modifier(RawTextFieldInputStyle())
                .modifier(ListItemTextFieldStyle())
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
            
            return Label("Time Created: \(createdText)", systemImage: "plus.circle")
        }
    }
    
    private var updatedDateTimeItem: some View {
        ZStack {
            var lastUpdatedText = Text("Never")

            if let lastUpdated = account.updatedDateTime {
                lastUpdatedText = Text("\(GlobalHelperDataService.dateFormatter.string(from: lastUpdated))")
            }
            
            return Label("Last Updated: \(lastUpdatedText)", systemImage: "pencil.circle")
        }
    }
    
    private var deleteItem: some View {
        Button("Delete") {
            accountsViewModel.accountToDelete = account
            showDeleteAlert.toggle()
        }
        .buttonStyle(ProminentButtonStyle(.red))
    }
}

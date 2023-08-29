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
    @State private var showDeleteAlert: Bool = false
    @State private var showPassword: Bool = false
    @State private var urlField: Bool = false
    @State private var showPasswordGeneratorSheet: Bool = false
    @FocusState private var nameTextFieldFocused: Bool
    @FocusState private var usernameTextFieldFocused: Bool
    @FocusState private var passwordTextFieldFocused: Bool
    @FocusState private var urlTextFieldFocused: Bool
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
                    
                    if account.url != nil {
                        urlItem
                    } else {
                        noUrlItem
                    }
                } else {
                    editUsernameItem
                    editPasswordItem
                    
                    if account.url != nil {
                        editUrlItem
                    } else {
                        noUrlItem
                    }
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
                    account.username = newUsername // Fix: is updating testAccounts directly!
                }
                
                if newPassword != "" {
                    account.password = newPassword
                }
                
                if newUrl != "" {
                    account.url = newUrl
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

extension AccountDetailView {
    private var titleItem: some View {
        ZStack {
            Text(account.name)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(2)
                .padding(.horizontal)
            
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
        .frame(height: accountsViewModel.viewItemHeight)
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
        .frame(height: accountsViewModel.viewItemHeight)
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
        .frame(height: accountsViewModel.viewItemHeight)
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
            
            @State var blankPassword = ""
            
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
        .frame(height: accountsViewModel.viewItemHeight)
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
        .frame(height: accountsViewModel.viewItemHeight)
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
                            withAnimation() {
                                account.url = newUrl
                            }
                            
                            account.updatedDateTime = Date()
                            accountsViewModel.updateAccount(id: account.id, account: account)
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
        .frame(height: accountsViewModel.viewItemHeight)
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

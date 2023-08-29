//
//  AccountDetailView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @Binding var account: Account
    @State private var showDeleteAlert: Bool = false
    @State private var showPassword: Bool = false
    @State private var urlField: Bool = false
    @State private var newUrl: String = ""
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
                Text(account.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .padding(.horizontal)
                    .padding(.top, accountsViewModel.showCopyPopupOverlay ? 30 : 0)

                usernameItem
                passwordItem

                if account.url != nil {
                    urlItem
                } else {
                    noUrlItem
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
        .overlay {
            PrivacyOverlayView()
        }
        .alert(isPresented: $showDeleteAlert) {
            accountsViewModel.getDeleteAlert()
        }
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        @StateObject var accountsViewModel = AccountsViewModel()
        @State var account = Account(name: "default", username: "default", password: "default")
        
        AccountDetailView(account: $account)
            .environmentObject(mainViewModel)
            .environmentObject(accountsViewModel)
    }
}

extension AccountDetailView {
    private var usernameItem: some View {
        Button {
            accountsViewModel.copyToClipboard(text: account.username)
            accountsViewModel.displayCopyPopupOverlay()
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
    
    private var passwordItem: some View {
        Button {
            accountsViewModel.copyToClipboard(text: account.password)
            accountsViewModel.displayCopyPopupOverlay()
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
    
    private var urlItem: some View {
        Button {
            accountsViewModel.copyToClipboard(text: account.url ?? "")
            accountsViewModel.displayCopyPopupOverlay()
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
                            accountsViewModel.updateAccount(account: account)
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

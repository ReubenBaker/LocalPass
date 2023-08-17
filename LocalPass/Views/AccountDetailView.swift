//
//  AccountDetailView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountDetailView: View {
    
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @State var showPassword: Bool = false
    @State var newUrl: String = ""
    @State var urlField: Bool = false
    var account: Account
    
    var body: some View {
        ScrollView {
            VStack {
                Text(account.name)
                    .font(.title)
                    .fontWeight(.semibold)
                
                usernameItem
                passwordItem
                
                if account.url != nil {
                    urlItem
                } else {
                    noUrlItem
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical)
        }
        .background(.ultraThinMaterial)
        .overlay(closeButton, alignment: .bottom)
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        AccountDetailView(account: AccountTestDataService.accounts.last!)
            .environmentObject(accountsViewModel)
    }
}

extension AccountDetailView {
    private var closeButton: some View {
        Button {
           accountsViewModel.selectedAccount = nil
       } label: {
           Image(systemName: "xmark")
               .font(.headline)
               .padding()
               .foregroundColor(.primary)
               .background(.thickMaterial)
               .cornerRadius(10)
               .shadow(radius: 4)
               .padding()
       }
    }
    
    private var usernameItem: some View {
        Button {
            accountsViewModel.copyToClipboard(text: account.username)
        } label: {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(account.username)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .foregroundColor(.primary)
            .padding()
        }
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(Color("AccentColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var passwordItem: some View {
        Button {
            accountsViewModel.copyToClipboard(text: account.password)
        } label: {
            HStack {
                Image(systemName: "lock.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(showPassword ? account.password : "************")
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.circle.fill" : "eye.circle.fill")
                        .resizable()
                        .scaledToFit()
                }
            }
            .foregroundColor(.primary)
            .padding()
        }
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(Color("AccentColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var urlItem: some View {
        Button {
            accountsViewModel.copyToClipboard(text: account.url ?? "")
        } label: {
            HStack {
                Image(systemName: "link.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(account.url ?? "")
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .foregroundColor(.primary)
            .padding()
        }
        .frame(height: 55)
        .frame(maxWidth: .infinity)
        .background(Color("AccentColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private var noUrlItem: some View {
        Button {
            withAnimation(.spring()) {
                urlField = true
            }
        } label: {
            if urlField {
                TextField("Enter url...", text: $newUrl)
            } else {
                Text("Add URL")
            }
        }
        .foregroundColor(.primary)
        .padding()
        .frame(height: 55)
        .frame(maxWidth: urlField ? .infinity : nil)
        .background(Color("AccentColor"))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

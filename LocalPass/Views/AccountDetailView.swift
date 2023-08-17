//
//  AccountDetailView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountDetailView: View {
    
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @State var showPassword: Bool = false
    let account: Account
    
    var body: some View {
        ScrollView {
            VStack {
                Text(account.name)
                    .font(.title)
                    .fontWeight(.semibold)
                
                usernameItem
                
                passwordItem
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
        @StateObject var accountViewModel = AccountViewModel()
        AccountDetailView(account: AccountTestDataService.accounts.first!)
            .environmentObject(accountViewModel)
    }
}

extension AccountDetailView {
    private var closeButton: some View {
        Button {
           accountViewModel.selectedAccount = nil
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
            
        } label: {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(account.username)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    accountViewModel.copyToClipboard(text: account.username)
                } label: {
                    Image(systemName: "clipboard.fill")
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
    
    private var passwordItem: some View {
        Button {
            
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
                
                Button {
                    accountViewModel.copyToClipboard(text: account.password)
                } label: {
                    Image(systemName: "clipboard.fill")
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
    
    private var urls: some View {
        Text("urls")
    }
}

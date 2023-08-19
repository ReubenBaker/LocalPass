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
    @State var urlField: Bool = false
    @State var newUrl: String = ""
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(accountsViewModel.selectedAccount?.name ?? "default")
                    .font(.title)
                    .fontWeight(.semibold)
                
                usernameItem
                passwordItem
                
                if accountsViewModel.selectedAccount?.url != nil {
                    urlItem
                } else {
                    noUrlItem
                }
                
                creationDateTimeItem
                UpdatedDateTimeItem
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
        
        AccountDetailView()
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
            
        } label: {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(accountsViewModel.selectedAccount?.username ?? "default")
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
            accountsViewModel.copyToClipboard(text: accountsViewModel.selectedAccount?.password ?? "default")
        } label: {
            HStack {
                Image(systemName: "lock.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(showPassword ? accountsViewModel.selectedAccount?.password ?? "default" : "************")
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
            accountsViewModel.copyToClipboard(text: accountsViewModel.selectedAccount?.url ?? "")
        } label: {
            HStack {
                Image(systemName: "link.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                Text(accountsViewModel.selectedAccount?.url ?? "")
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
            withAnimation() {
                urlField = true
            }
        } label: {
            if urlField {
                HStack() {
                    TextField("Enter url...", text: $newUrl)
                        .multilineTextAlignment(.leading)
                        .onSubmit {
                            withAnimation() {
                                accountsViewModel.selectedAccount?.url = newUrl
                            }
                            
                            if let index = accountsViewModel.testAccounts.firstIndex(where: { $0.id == accountsViewModel.selectedAccount?.id }) {
                                accountsViewModel.updateAccount(index: index)
                            }
                        }
                    
                    Button {
                        withAnimation() {
                            urlField = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
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
    
    private var creationDateTimeItem: some View {
        Text("Time Created: \(dateFormatter.string(from: accountsViewModel.selectedAccount?.creationDateTime ?? .now))")
    }
    
    private var UpdatedDateTimeItem: some View {
        Text("Last Updated: \(dateFormatter.string(from: accountsViewModel.selectedAccount?.updatedDateTime ?? .now))")
    }
}

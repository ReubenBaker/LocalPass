//
//  FileManagerTestView.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import SwiftUI

struct FileManagerTestView: View {
    
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                if accountsViewModel.accounts != nil {
                    ForEach(accountsViewModel.accounts!) { account in
                        Text("\(account.name) \(account.username) \(account.password) \(account.url != nil ? account.url! : "nil") \(account.creationDateTime.formatted()) \(account.updatedDateTime != nil ? String(describing: account.updatedDateTime!) : String(describing: account.updatedDateTime)) \(String(describing: account.starred))\n")
                    }
                }
            }
        }
        .padding()
    }
}

struct FileManagerTestView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        
        FileManagerTestView()
            .environmentObject(accountsViewModel)
    }
}

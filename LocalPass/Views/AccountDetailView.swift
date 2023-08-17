//
//  AccountDetailView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct AccountDetailView: View {
    
    let account: Account
    
    var body: some View {
        VStack {
            Text(account.name)
            Text(account.username)
        }
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AccountDetailView(account: AccountTestDataService.accounts.first!)
    }
}

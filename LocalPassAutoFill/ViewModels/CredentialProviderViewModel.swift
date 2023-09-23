//
//  CredentialProviderViewModel.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 23/09/2023.
//

import Foundation
import AuthenticationServices

class CredentialProviderViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    
    func provideCredential() -> ASPasswordCredential {
        return ASPasswordCredential(user: username, password: password)
    }
}

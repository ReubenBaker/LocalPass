//
//  AuthenticationViewModel.swift
//  LocalPass
//
//  Created by Reuben on 10/09/2023.
//

import Foundation
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    static var shared = AuthenticationViewModel()
    
    @Published var password: String? = nil
    @Published var authenticated: Bool = false
    @Published var authenticatedWithBiometrics: Bool = false
    
    static func rotateKey(_ password: String?) {
        if let password = password {
            let accounts = AccountsDataService.getAccountData()
            let notes = NotesDataService.getNoteData()
         
            if let salt = CryptoDataService.generateRandomSalt(),
               let newKey = CryptoDataService.deriveKey(password: password, salt: salt),
               let tag = Bundle.main.bundleIdentifier {
                    if CryptoDataService.deleteKey(tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync)
                    && CryptoDataService.setkey(key: newKey, tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync) {
                        do {
                            try AccountsDataService.saveData(accounts, salt: salt)
                            try NotesDataService.saveData(notes, salt: salt)
                        } catch {
                            print("Error rewriting data with new key: \(error)")
                        }
                    }
            }
        }
    }
    
    static func getIncorrectPasswordAlert() -> Alert {
        let title: Text = Text("Your password was incorrect!")
        let message: Text = Text("Please try again")
        let dismissButton: Alert.Button = .default(Text("😢"))
        
        return Alert(
            title: title,
            message: message,
            dismissButton: dismissButton
        )
    }
}

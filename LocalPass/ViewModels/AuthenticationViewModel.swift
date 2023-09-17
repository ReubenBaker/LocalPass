//
//  AuthenticationViewModel.swift
//  LocalPass
//
//  Created by Reuben on 10/09/2023.
//

import Foundation
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var password: String? = nil
    @Published var authenticated: Bool = false {
        didSet {
            if authenticated && !authenticatedWithBiometrics {
                rotateKey()
            }
        }
    }
    @Published var authenticatedWithBiometrics: Bool = false
    
    func getIncorrectPasswordAlert() -> Alert {
        let title: Text = Text("Your password was incorrect!")
        let message: Text = Text("Please try again")
        let dismissButton: Alert.Button = .default(Text("OK"))
        
        return Alert(
            title: title,
            message: message,
            dismissButton: dismissButton
        )
    }
    
    func getBiometricsNotAllowedAlert() -> Alert {
        let title: Text = Text("Biometrics is currently not allowed!")
        let message: Text = Text("Please use your password to authenticate instead")
        let dismissButton: Alert.Button = .default(Text("OK"))
        
        return Alert(
            title: title,
            message: message,
            dismissButton: dismissButton
        )
    }
    
    func rotateKey() {
        if let password = self.password {
            let accountsDataService = AccountsDataService()
            let notesDataService = NotesDataService()
            let cryptoDataService = CryptoDataService()
            let accounts = accountsDataService.getAccountData()
            let notes = notesDataService.getNoteData()
         
            if let salt = cryptoDataService.generateRandomSalt() {
                if let newKey = cryptoDataService.deriveKey(password: password, salt: salt) {
                    if let tag = Bundle.main.bundleIdentifier {
                        if cryptoDataService.deleteKeyFromSecureEnclave(tag: tag) {
                            if cryptoDataService.writeKeyToSecureEnclave(key: newKey, tag: tag) {
                                do {
                                    try accountsDataService.saveData(accounts: accounts, salt: salt)
                                    try notesDataService.saveData(notes: notes, salt: salt)
                                } catch {
                                    print("Error rewriting data with new key: \(error)")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

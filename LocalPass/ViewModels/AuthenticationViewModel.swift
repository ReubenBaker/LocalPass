//
//  AuthenticationViewModel.swift
//  LocalPass
//
//  Created by Reuben on 10/09/2023.
//

import Foundation
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    static let shared = AuthenticationViewModel()
    
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
            let accounts = AccountsDataService.getAccountData()
            let notes = NotesDataService.getNoteData()
         
            if let salt = CryptoDataService.generateRandomSalt() {
                if let newKey = CryptoDataService.deriveKey(password: password, salt: salt) {
                    if let tag = Bundle.main.bundleIdentifier {
                        if CryptoDataService.deleteKeyFromSecureEnclave(tag: tag) {
                            if CryptoDataService.writeKeyToSecureEnclave(key: newKey, tag: tag) {
                                do {
                                    try AccountsDataService.saveData(accounts, salt: salt)
                                    try NotesDataService.saveData(notes: notes, salt: salt)
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

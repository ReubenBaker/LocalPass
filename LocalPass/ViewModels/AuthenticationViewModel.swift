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
    
    func getIncorrectPasswordAlert() -> Alert {
        let title: Text = Text("Your password was incorrect!")
        let message: Text = Text("Please try again")
        let dismissButton: Alert.Button = .default(Text("😢"))
        
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
}

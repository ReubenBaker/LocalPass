//
//  SignUpViewModel.swift
//  LocalPass
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI
import CryptoKit

class SignUpViewModel: ObservableObject {
    static func signUp(password: String?, _ authenticationViewModel: AuthenticationViewModel) {
        if let tag = Bundle.main.bundleIdentifier,
           let salt = CryptoDataService.generateRandomSalt(),
           let password = password,
           let key = CryptoDataService.deriveKey(password: password, salt: salt) {
            if CryptoDataService.deleteKey(tag: tag)
            && CryptoDataService.setkey(key: key, tag: tag)
            && SignUpViewModel.createFiles(key: key, salt: salt) {
                AuthenticationViewModel.shared.authenticated = true
                authenticationViewModel.authenticated = true
                LocalPassApp.settings.signedUp = true
            }
        }
    }
    
    static func createFiles(key: SymmetricKey, salt: Data) -> Bool {
        let blob: String = "empty"
        
        let accountsPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.reuben.LocalPass")?.appendingPathComponent("localpassaccounts.txt")
        let notesPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.reuben.LocalPass")?.appendingPathComponent("localpassnotes.txt")
        
        if let tag = Bundle.main.bundleIdentifier,
           let key = CryptoDataService.readKey(tag: tag),
           let encryptedBlob = CryptoDataService.encryptBlob(blob: blob, key: key, salt: salt) {
            do {
                if let accountsPath = accountsPath,
                   let notesPath = notesPath {
                    try encryptedBlob.write(to: accountsPath, options: .atomic)
                    try encryptedBlob.write(to: notesPath, options: .atomic)
                }
                
                return true
            } catch {
                print("Error creating files: \(error)")
                }
        }
        
        return false
    }
    
    static func isValidPassword(_ password: String?) -> Bool {
        if let password = password {
            let passwordRegex = "^(?=.*[0-9])(?=.*[!@#\\$%^&*()_\\-+=\\[\\]{}|;:'\",.<>?/\\\\~]).{12,}$"
            
            let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
            return passwordPredicate.evaluate(with: password)
        }
        
        return false
    }
    
    static func getInvalidPasswordAlert() -> Alert {
        let title = Text("Your password is invalid!")
        let message = Text("Please try again")
        let dismissButton: Alert.Button = .default(Text("😢"))
        
        return Alert(
            title: title,
            message: message,
            dismissButton: dismissButton
        )
    }
    
    static func getPasswordMismatchAlert() -> Alert {
        let title = Text("Your passwords do not match!")
        let message = Text("Please try again")
        let dismissButton: Alert.Button = .default(Text("😢"))
        
        return Alert(
            title: title,
            message: message,
            dismissButton: dismissButton
        )
    }
}

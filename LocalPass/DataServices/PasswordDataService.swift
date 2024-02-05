//
//  PasswordDataService.swift
//  LocalPass
//
//  Created by Reuben on 30/08/2023.
//

import Foundation

class PasswordDataService {
    func generatePassword(characterCount: Int, numericalCount: Int, specialCount: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let specials = "!@#$%^&*()_-+=[]{}|;:'\",.<>?/\\~`"
        var password = ""
        
        for _ in 0..<numericalCount {
            if let randomNumber = numbers.randomElement() {
                password += "\(randomNumber)"
            }
        }
        
        for _ in 0..<specialCount {
            if let randomSpecial = specials.randomElement() {
                password += "\(randomSpecial)"
            }
        }
        
        for _ in 0..<characterCount - numericalCount - specialCount {
            if let randomCharacter = characters.randomElement() {
                password += "\(randomCharacter)"
            }
        }
        
        return String(password.shuffled())
    }
    
    func calculatePasswordEntropy(password: String) -> Double {
        // Assumes 26 lowercase, 26 uppercase, 10 digits, and 32 special characters
        let characters: Double = 94
        
        let length = Double(password.count)
        
        let entropy = length * log2(characters)
        
        return entropy
    }
}

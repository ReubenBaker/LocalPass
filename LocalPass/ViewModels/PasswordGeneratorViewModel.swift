//
//  PasswordGeneratorViewModel.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import Foundation

class PasswordGeneratorViewModel: ObservableObject {
    func generatePassword(characterCount: Int, numericalCount: Int, specialCount: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let specials = "!@£$%^&*()#-_=+;:\'\"\\|,<.>/?`~"
        var password = ""
        
        for _ in 0..<numericalCount {
            let randomNumber = numbers.description.randomElement()!
            password += "\(randomNumber)"
        }
        
        for _ in 0..<specialCount {
            let randomSpecial = specials.randomElement()!
            password += "\(randomSpecial)"
        }
        
        for _ in 0..<characterCount - numericalCount - specialCount {
            let randomCharacter = characters.randomElement()!
            password += "\(randomCharacter)"
        }
        
        return String(password.shuffled())
    }
}

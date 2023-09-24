//
//  AuthenticationViewModel.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    static var shared = AuthenticationViewModel()
    
    @Published var password: String? = nil
    @Published var authenticated: Bool = false
    @Published var authenticatedWithBiometrics: Bool = false
    
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

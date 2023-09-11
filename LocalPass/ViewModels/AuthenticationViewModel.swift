//
//  AuthenticationViewModel.swift
//  LocalPass
//
//  Created by Reuben on 10/09/2023.
//

import Foundation
import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var password: String? = "password123"
    @Published var authenticated: Bool = false
    
    func getIncorrectPasswordAlert () -> Alert {
        let title: Text = Text("Your password was incorrect!")
        let message: Text = Text("Please Try Again")
        let dismissButton: Alert.Button = .default(Text("OK"))
        
        return Alert(
            title: title,
            message: message,
            dismissButton: dismissButton
        )
    }
}

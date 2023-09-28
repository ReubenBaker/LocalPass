//
//  GlobalHelperDataService.swift
//  LocalPass
//
//  Created by Reuben on 18/09/2023.
//

import Foundation
import SwiftUI
import LocalAuthentication

// Instances
struct GlobalHelperDataService {
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
    static let sortOptions: [String] = [
        "Date Added Ascending", "Date Added Descending", "Alphabetical"
    ]
    
    enum FocusedTextField: Hashable {
        case name, username, password, url, otpSecret
        case title, body
        case passwordConfirmation
    }
}

// Functions
extension GlobalHelperDataService {
    static func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    static func getBiometrySymbol() -> String {
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            if context.biometryType == .faceID {
                return "faceid"
            } else if context.biometryType == .touchID {
                return "touchid"
            }
        }
        
        return "key.viewfinder"
    }
}

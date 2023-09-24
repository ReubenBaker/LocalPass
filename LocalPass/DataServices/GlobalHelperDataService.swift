//
//  GlobalHelperDataService.swift
//  LocalPass
//
//  Created by Reuben on 18/09/2023.
//

import Foundation
import SwiftUI

// Instances
struct GlobalHelperDataService {
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }
    
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
}

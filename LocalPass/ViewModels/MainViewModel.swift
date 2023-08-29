//
//  MainViewModel.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    func copyToClipboard(text: String) {
        UIPasteboard.general.string = text
    }
}

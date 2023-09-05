//
//  SettingsModel.swift
//  LocalPass
//
//  Created by Reuben on 05/09/2023.
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    static let shared = Settings()
    
    @AppStorage("iCloudSync") var iCloudSync: Bool = false {
        didSet {
            objectWillChange.send()
        }
    }
}

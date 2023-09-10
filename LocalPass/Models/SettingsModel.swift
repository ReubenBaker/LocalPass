//
//  SettingsModel.swift
//  LocalPass
//
//  Created by Reuben on 05/09/2023.
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    @Published var signedUp: Bool = true {
        didSet {
            UserDefaults.standard.set(signedUp, forKey: "signedUp")
        }
    }
    
    @Published var iCloudSync: Bool = false {
        didSet {
            UserDefaults.standard.set(iCloudSync, forKey: "iCloudSync")
        }
    }
    
    init() {
        self.signedUp = UserDefaults.standard.bool(forKey: "signedUp")
        self.iCloudSync = UserDefaults.standard.bool(forKey: "iCloudSync")
    }
}

//
//  SettingsModel.swift
//  LocalPass
//
//  Created by Reuben on 05/09/2023.
//

import Foundation
import SwiftUI
import LocalAuthentication

class Settings {
    static var shared = Settings()
    
    var signedUp: Bool = true {
        didSet {
            UserDefaults.standard.set(signedUp, forKey: "signedUp")
        }
    }
    
    var iCloudSync: Bool = false {
        didSet {
            UserDefaults.standard.set(iCloudSync, forKey: "iCloudSync")
        }
    }
    
    var showFavicons: Bool = false {
        didSet {
            UserDefaults.standard.set(showFavicons, forKey: "showFavicons")
        }
    }
    
    var useBiometrics: Bool = false {
        didSet {
            UserDefaults.standard.set(useBiometrics, forKey: "useBiometrics")
            
            if useBiometrics == true && LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                biometricsAllowed = true
            } else {
                biometricsAllowed = false
            }
        }
    }
    
    var biometricsAllowed: Bool = false {
        didSet {
            UserDefaults.standard.set(biometricsAllowed, forKey: "biometricsAllowed")
        }
    }
    
    init() {
        self.signedUp = UserDefaults.standard.bool(forKey: "signedUp")
        self.iCloudSync = UserDefaults.standard.bool(forKey: "iCloudSync")
        self.showFavicons = UserDefaults.standard.bool(forKey: "showFavicons")
        self.useBiometrics = UserDefaults.standard.bool(forKey: "useBiometrics")
        self.biometricsAllowed = UserDefaults.standard.bool(forKey: "biometricsAllowed")
    }
}

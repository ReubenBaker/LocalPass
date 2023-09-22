//
//  SettingsModel.swift
//  LocalPass
//
//  Created by Reuben on 05/09/2023.
//

import Foundation
import SwiftUI
import LocalAuthentication

class Settings: ObservableObject {
    static var shared = Settings()
    
    @Published var signedUp: Bool {
        didSet {
            UserDefaults.standard.set(signedUp, forKey: "signedUp")
        }
    }
    
    @Published var iCloudSync: Bool {
        didSet {
            UserDefaults.standard.set(iCloudSync, forKey: "iCloudSync")
        }
    }
    
    @Published var showFavicons: Bool {
        didSet {
            UserDefaults.standard.set(showFavicons, forKey: "showFavicons")
        }
    }
    
    @Published var useBiometrics: Bool {
        didSet {
            UserDefaults.standard.set(useBiometrics, forKey: "useBiometrics")
            
            if useBiometrics == true && LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                useBiometrics = true
                biometricsAllowed = true
            } else {
                useBiometrics = false
                biometricsAllowed = false
            }
        }
    }
    
    @Published var biometricsAllowed: Bool {
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

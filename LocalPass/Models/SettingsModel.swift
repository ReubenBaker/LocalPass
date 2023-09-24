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
            
            if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
                sharedUserDefaults.set(signedUp, forKey: "signedUp")
                sharedUserDefaults.synchronize()
            }
        }
    }
    
    @Published var iCloudSync: Bool {
        didSet {
            UserDefaults.standard.set(iCloudSync, forKey: "iCloudSync")
            
            if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
                sharedUserDefaults.set(iCloudSync, forKey: "iCloudSync")
                sharedUserDefaults.synchronize()
            }
        }
    }
    
    @Published var showFavicons: Bool {
        didSet {
            UserDefaults.standard.set(showFavicons, forKey: "showFavicons")
            
            if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
                sharedUserDefaults.set(showFavicons, forKey: "showFavicons")
                sharedUserDefaults.synchronize()
            }
        }
    }
    
    @Published var useBiometrics: Bool {
        didSet {
            UserDefaults.standard.set(useBiometrics, forKey: "useBiometrics")
            
            if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
                sharedUserDefaults.set(useBiometrics, forKey: "useBiometrics")
                sharedUserDefaults.synchronize()
            }
        }
    }
    
    @Published var lockVaultOnBackground: Bool {
        didSet {
            UserDefaults.standard.set(lockVaultOnBackground, forKey: "lockVaultOnBackground")
            
            if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
                sharedUserDefaults.set(lockVaultOnBackground, forKey: "lockVaultOnBackground")
                sharedUserDefaults.synchronize()
            }
        }
    }
    
    init() {
        if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
            self.signedUp = sharedUserDefaults.bool(forKey: "signedUp")
            self.iCloudSync = sharedUserDefaults.bool(forKey: "iCloudSync")
            self.showFavicons = sharedUserDefaults.bool(forKey: "showFavicons")
            self.useBiometrics = sharedUserDefaults.bool(forKey: "useBiometrics")
            self.lockVaultOnBackground = sharedUserDefaults.bool(forKey: "lockVaultOnBackground")
        } else {
            self.signedUp = UserDefaults.standard.bool(forKey: "signedUp")
            self.iCloudSync = UserDefaults.standard.bool(forKey: "iCloudSync")
            self.showFavicons = UserDefaults.standard.bool(forKey: "showFavicons")
            self.useBiometrics = UserDefaults.standard.bool(forKey: "useBiometrics")
            self.lockVaultOnBackground = UserDefaults.standard.bool(forKey: "lockVaultOnBackground")
        }
    }
}

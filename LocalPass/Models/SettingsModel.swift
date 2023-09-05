//
//  SettingsModel.swift
//  LocalPass
//
//  Created by Reuben on 05/09/2023.
//

import Foundation
import SwiftUI

class Settings: ObservableObject {
    @Published var iCloudSync: Bool = false {
        didSet {
            UserDefaults.standard.set(iCloudSync, forKey: "iCloudSync")
            
            if iCloudSync == false {
                AccountsDataService().removeiCloudData()
                NotesDataService().removeiCloudData()
            }
        }
    }
    
    init() {
        self.iCloudSync = UserDefaults.standard.bool(forKey: "iCloudSync")
    }
}

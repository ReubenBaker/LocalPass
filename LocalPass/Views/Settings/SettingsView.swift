//
//  SettingsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    
    @StateObject private var settings = LocalPassApp.settings
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("About")) {
                    NavigationLink("About LocalPass") {
                        AboutView()
                            .navigationTitle("About LocalPass")
                    }
                }
                
                Section(header: Text("Settings")) {
                    Toggle("iCloud Sync", isOn: $settings.iCloudSync)
                        .onChange(of: settings.iCloudSync) { newValue in
                            LocalPassApp.settings.iCloudSync = newValue
                            
                            if let tag = Bundle.main.bundleIdentifier {
                                if let currentKey = CryptoDataService.readKey(tag: tag) {
                                    _ = CryptoDataService.deleteKey(tag: tag, iCloudSync: true)
                                    _ = CryptoDataService.setkey(key: currentKey, tag: tag, iCloudSync: newValue)
                                }
                            }
                            
                            if newValue == true {
                                do {
                                    try AccountsDataService.saveData(AccountsDataService.getAccountData())
                                    try NotesDataService.saveData(NotesDataService.getNoteData())
                                } catch {
                                    print("Error writing data to iCloud: \(error)")
                                }
                            } else {
                                AccountsDataService.removeiCloudData()
                                NotesDataService.removeiCloudData()
                            }
                        }
                    
                    Toggle("Show Account Icons", isOn: $settings.showFavicons)
                        .onChange(of: settings.showFavicons) { newValue in
                            LocalPassApp.settings.showFavicons = newValue
                        }
                    
                    let biometricsEnrolled = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
                    
                    Toggle("Use Biometrics", isOn: $settings.useBiometrics)
                        .onChange(of: Settings.shared.useBiometrics) { newValue in
                            LocalPassApp.settings.useBiometrics = newValue
                            
                            if newValue == true {
                                let context = LAContext()
                                var error: NSError?

                                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enable biometric authentication") { success, authenticationError in
                                        DispatchQueue.main.async {
                                            if success {
                                                Settings.shared.useBiometrics = true
                                            } else {
                                                Settings.shared.useBiometrics = false
                                            }
                                        }
                                    }
                                }
                            } else {
                                Settings.shared.useBiometrics = false
                            }
                        }
                        .disabled(!biometricsEnrolled)
                        .foregroundColor(biometricsEnrolled ? .primary : .primary.opacity(0.5))
                }
            }
        }
        .navigationTitle("Settings")
        .listStyle(InsetGroupedListStyle())
    }
}

// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

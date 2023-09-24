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
    @State private var showAboutView: Bool = false
    let biometricsEnrolled = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("About")) {
                    Button {
                        showAboutView.toggle()
                    } label: {
                        Text("About LocalPass")
                    }
                    .fullScreenCover(isPresented: $showAboutView) {
                        AboutView()
                    }
                }
                
                Section(header: Text("Settings")) {
                    Toggle("iCloud Sync (Beta)", isOn: $settings.iCloudSync)
                        .onChange(of: settings.iCloudSync) { newValue in
                            if let accounts = AccountsDataService.getAccountData(),
                               let notes = NotesDataService.getNoteData(),
                               let blob = AccountsDataService.getBlob() {
                                
                                let salt = blob.prefix(16)
                                
                                LocalPassApp.settings.iCloudSync = newValue
                                
                                if let tag = Bundle.main.bundleIdentifier {
                                    if let currentKey = CryptoDataService.readKey(tag: tag) {
                                        _ = CryptoDataService.deleteKey(tag: tag, iCloudSync: true)
                                        _ = CryptoDataService.setkey(key: currentKey, tag: tag, iCloudSync: newValue)
                                    }
                                }
                                
                                if newValue == true {
                                    AccountsDataService.saveData(accounts, salt: salt)
                                    NotesDataService.saveData(notes, salt: salt)
                                } else {
                                    AccountsDataService.removeiCloudData()
                                    NotesDataService.removeiCloudData()
                                }
                            }
                        }
                    
                    Toggle("Show Account Icons", isOn: $settings.showFavicons)
                        .onChange(of: settings.showFavicons) { newValue in
                            LocalPassApp.settings.showFavicons = newValue
                        }
                    
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
                    
                        Toggle("Lock Vault When Inactive", isOn: $settings.lockVaultOnBackground)
                            .onChange(of: settings.lockVaultOnBackground) { newValue in
                                LocalPassApp.settings.lockVaultOnBackground = newValue
                            }
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

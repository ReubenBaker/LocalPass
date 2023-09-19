//
//  SettingsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("About")) {
                    NavigationLink("About LocalPass") {
                        AboutView()
                    }
                }
                
                Section(header: Text("Settings")) {
                    Toggle("iCloud Sync", isOn: Binding(
                        get: { Settings.shared.iCloudSync },
                        set: { newValue in
                            Settings.shared.iCloudSync = newValue
                        }
                    ))
                        .onChange(of: Settings.shared.iCloudSync) { setting in
                            if setting == true {
                                do {
                                    try AccountsDataService.saveData(AccountsDataService.getAccountData())
                                    try NotesDataService.saveData(notes: NotesDataService.getNoteData())
                                } catch {
                                    print("Error writing data to iCloud: \(error)")
                                }
                            } else {
                                AccountsDataService.removeiCloudData()
                                NotesDataService.removeiCloudData()
                            }
                        }
                    
                    Toggle("Show Account Icons", isOn: Binding(
                        get: { Settings.shared.showFavicons },
                        set: { newValue in
                            Settings.shared.showFavicons = newValue
                        }
                    ))
                    
                    let biometricsEnrolled = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
                    
                    Toggle("Use Biometrics", isOn: Binding(
                        get: { Settings.shared.useBiometrics },
                        set: { newValue in
                            Settings.shared.useBiometrics = newValue
                        }
                    ))
                        .onChange(of: Settings.shared.useBiometrics) { setting in
                            if setting == true {
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

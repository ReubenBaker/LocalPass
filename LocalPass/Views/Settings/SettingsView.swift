//
//  SettingsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    
    @EnvironmentObject private var settings: Settings
    private var accountsDataService = AccountsDataService()
    private var notesDataService = NotesDataService()
    private var cryptoDataService = CryptoDataService()
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("About")) {
                    NavigationLink("About") {
                        AboutView()
                    }
                }
                
                Section(header: Text("Settings")) {
                    Toggle("iCloud Sync", isOn: $settings.iCloudSync)
                        .onChange(of: settings.iCloudSync) { setting in
                            if setting == true {
                                do {
                                    try accountsDataService.saveData(accounts: accountsDataService.getAccountData())
                                } catch {
                                    print("Error writing accounts data: \(error)")
                                }
                                
                                do {
                                    try notesDataService.saveData(notes: notesDataService.getNoteData())
                                } catch {
                                    print("Error writing notes data: \(error)")
                                }
                            } else {
                                accountsDataService.removeiCloudData()
                                notesDataService.removeiCloudData()
                            }
                        }
                    
                    Toggle("Signed Up: \(settings.signedUp.description)", isOn: $settings.signedUp)
                    
                    Toggle("Show URL Icons", isOn: $settings.showFavicons)
                    
                    let biometricsEnrolled = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
                    
                    Toggle("Use Biometrics", isOn: $settings.useBiometrics)
                        .onChange(of: settings.useBiometrics) { setting in
                            if setting == true {
                                let context = LAContext()
                                var error: NSError?
                                
                                if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enable biometric authentication") { success, authenticationError in
                                        DispatchQueue.main.async {
                                            if success {
                                                settings.useBiometrics = true
                                            } else {
                                                settings.useBiometrics = false
                                            }
                                        }
                                    }
                                }
                            } else {
                                settings.useBiometrics = false
                            }
                        }
                        .disabled(!biometricsEnrolled)
                        .foregroundColor(biometricsEnrolled ? .primary : .primary.opacity(0.5))
                }
                
                Section(header: Text("Tests")) {
                    Button {
//                        CryptoDataService().test()
                    } label: {
                        Text("Test Crypto")
                    }
                    
                    Button {
//                        CryptoDataService().testBiometrics()
                    } label: {
                        Text("Test Crypto - Biometrics")
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
        @StateObject var settings = Settings()
        
        SettingsView()
            .environmentObject(settings)
    }
}

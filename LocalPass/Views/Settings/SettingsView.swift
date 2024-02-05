//
//  SettingsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    
    @Environment(\.scenePhase) private var scenePhase
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
                            .overlay(PrivacyOverlayView())
                            .environment(\.scenePhase, scenePhase)
                    }
                    .onChange(of: scenePhase) { phase in
                        if phase != .active && LocalPassApp.settings.lockVaultOnBackground {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showAboutView = false
                            }
                        }
                    }
                }
                
                Section(header: Text("Settings")) {
                    Toggle("Use Biometrics \(Image(systemName: GlobalHelperDataService.biometrySymbol).symbolRenderingMode(LocalPassApp.settings.useBiometrics ? .multicolor : .monochrome))", isOn: $settings.useBiometrics)
                        .onChange(of: Settings.shared.useBiometrics) { newValue in
                            LocalPassApp.settings.useBiometrics = newValue
                            
                            if newValue {
                                let context = LAContext()
                                let lockVaultOnBackground = settings.lockVaultOnBackground
                                LocalPassApp.settings.lockVaultOnBackground = false

                                if biometricsEnrolled {
                                    context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enable biometric authentication") { success, authenticationError in
                                        DispatchQueue.main.async {
                                            LocalPassApp.settings.lockVaultOnBackground = lockVaultOnBackground
                                            
                                            Settings.shared.useBiometrics = success
                                        }
                                    }	
                                }
                            } else {
                                Settings.shared.useBiometrics = false
                            }
                        }
                        .disabled(!biometricsEnrolled)
                        .foregroundColor(biometricsEnrolled ? .primary : .primary.opacity(0.5))
                    
                    Toggle("Show Account Icons \(Image(systemName: LocalPassApp.settings.showFavicons ? "paintpalette.fill" : "paintpalette").symbolRenderingMode(LocalPassApp.settings.showFavicons ? .multicolor : .monochrome))", isOn: $settings.showFavicons)
                        .onChange(of: settings.showFavicons) { newValue in
                            LocalPassApp.settings.showFavicons = newValue
                        }
                
                    Toggle("Lock Vault When Inactive \(Image(systemName: LocalPassApp.settings.lockVaultOnBackground ? "lock.trianglebadge.exclamationmark" : "lock.open.trianglebadge.exclamationmark").symbolRenderingMode(.multicolor))", isOn: $settings.lockVaultOnBackground)
                        .onChange(of: settings.lockVaultOnBackground) { newValue in
                            LocalPassApp.settings.lockVaultOnBackground = newValue
                        }
                }
                
                Section(header: Text("Coming Soon")) {
                    Toggle("iCloud Sync \(Image(systemName: LocalPassApp.settings.iCloudSync ? "icloud.fill" : "icloud").symbolRenderingMode(LocalPassApp.settings.iCloudSync ? .multicolor : .monochrome))", isOn: $settings.iCloudSync)
                        .onChange(of: settings.iCloudSync) { newValue in
                            
                        }
                        .disabled(true) // Not ready
                        .foregroundColor(.primary.opacity(0.5))
                    
                    
                    Toggle("Recycle Bin \(Image(systemName: LocalPassApp.settings.recycleBin ? "trash.fill" : "trash").symbolRenderingMode(LocalPassApp.settings.recycleBin ? .multicolor : .monochrome))", isOn: $settings.recycleBin)
                        .onChange(of: settings.recycleBin) { newValue in
                            LocalPassApp.settings.recycleBin = newValue
                        }
                        .disabled(true) // Not ready
                        .foregroundColor(.primary.opacity(0.5))
                    
                    Toggle("Password Change Reminders \(Image(systemName: LocalPassApp.settings.passwordChangeReminders ? "bell.badge.fill" : "bell.badge").symbolRenderingMode(LocalPassApp.settings.passwordChangeReminders ? .multicolor : .monochrome))", isOn: $settings.passwordChangeReminders)
                        .onChange(of: settings.passwordChangeReminders) { newValue in
                            LocalPassApp.settings.passwordChangeReminders = newValue
                        }
                        .disabled(true) // Not ready
                        .foregroundColor(.primary.opacity(0.5))
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

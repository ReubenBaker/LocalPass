//
//  SettingsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject private var settings: Settings
    
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
                                    try AccountsDataService().saveData(accounts: AccountsDataService().getAccountData())
                                } catch {
                                    print("Error writing accounts data: \(error)")
                                }
                                
                                do {
                                    try NotesDataService().saveData(notes: NotesDataService().getNoteData())
                                } catch {
                                    print("Error writing notes data: \(error)")
                                }
                            } else {
                                AccountsDataService().removeiCloudData()
                                NotesDataService().removeiCloudData()
                            }
                        }
                    
                    Toggle("Signed Up: \(settings.signedUp.description)", isOn: $settings.signedUp)
                    
                    Toggle("Show URL Icons", isOn: $settings.showFavicons)
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

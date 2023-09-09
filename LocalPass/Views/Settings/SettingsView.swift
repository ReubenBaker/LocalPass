//
//  SettingsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var settings = Settings()
    
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
                                AccountsDataService().saveData(accounts: AccountsDataService().getAccountData())
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

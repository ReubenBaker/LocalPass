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
                    Toggle("iCloud", isOn: $settings.iCloudSync)
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

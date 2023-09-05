//
//  SettingsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("About")) {
                    NavigationLink("About") {
                        AboutView()
                    }
                }
                
                Section(header: Text("Settings")) {
                    Toggle("iCloud", isOn: Settings.shared.$iCloudSync)
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

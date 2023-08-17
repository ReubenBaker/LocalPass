//
//  SettingsView.swift
//  LocalPass
//
//  Created by Reuben on 17/08/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @State var testText: String = ""
    
    var body: some View {
        VStack {
            Text("Settings View")
            TextField("Test", text: $testText)
                .padding()
            NavigationStack {
                
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

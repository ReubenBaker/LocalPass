//
//  MainView.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 23/09/2023.
//

import SwiftUI
import AuthenticationServices

struct MainView: View {
    
    @ObservedObject var credentialProviderViewModel: CredentialProviderViewModel
    var autoFill: (() -> Void)?
    
    var body: some View {
        VStack {
            Text("Coming Soon")
                .padding()
                .font(.largeTitle)
            
            Button {
                credentialProviderViewModel.username = "test_username"
                credentialProviderViewModel.password = "test_password"
                
                self.autoFill?()
            } label: {
                Text("AutoFill Default Credentials")
            }
            .buttonStyle(BorderedButtonStyle())
            .cornerRadius(10)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var credentialProviderViewModel = CredentialProviderViewModel()
        
        MainView(credentialProviderViewModel: credentialProviderViewModel)
    }
}

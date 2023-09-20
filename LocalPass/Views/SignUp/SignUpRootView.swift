//
//  SignUpRootView.swift
//  LocalPass
//
//  Created by Reuben on 20/09/2023.
//

import SwiftUI

struct SignUpRootView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Welcome to LocalPass!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image("AppIconImageRoundedCorners")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: UIScreen.main.bounds.width / 3)
                    .padding()
                
                Spacer()
                
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("Get Started!")
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(10)
                
                NavigationLink {
                    
                } label: {
                    Text("Already Use LocalPass?")
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial.opacity(0.5))
                .cornerRadius(10)
                
                NavigationLink {
                    AboutView()
                } label: {
                    Text("About LocalPass")
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial.opacity(0.25))
                .cornerRadius(10)
                
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color("AppThemeColor"))
        }
    }
}

struct SignUpRootView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpRootView()
    }
}

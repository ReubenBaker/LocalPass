//
//  SignUpRootView.swift
//  LocalPass
//
//  Created by Reuben on 20/09/2023.
//

import SwiftUI

struct SignUpRootView: View {
    
    @State private var showAboutView: Bool = false
    
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
                .background(.ultraThickMaterial.opacity(0.75))
                .cornerRadius(10)
                
                NavigationLink {
                    SignUpReturningView()
                } label: {
                    Text("Already Use LocalPass?")
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThickMaterial.opacity(0.5))
                .cornerRadius(10)
                
                Button {
                    showAboutView.toggle()
                } label: {
                    Text("About LocalPass")
                        .foregroundColor(.white)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(.ultraThickMaterial.opacity(0.25))
                .cornerRadius(10)
                .fullScreenCover(isPresented: $showAboutView) {
                    AboutView()
                }
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

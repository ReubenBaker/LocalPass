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
                titleItem
                Spacer()
                logoItem
                Spacer()
                navigationItem
            }
            .modifier(SignUpViewStyle())
        }
    }
}

struct SignUpRootView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpRootView()
    }
}

// Views
extension SignUpRootView {
    private var titleItem: some View {
        Text("Welcome to LocalPass!")
            .font(.largeTitle)
    }
    
    private var logoItem: some View {
        Image("AppIconImageRoundedCorners")
            .LogoIconStyle(large: true)
    }
    
    private var navigationItem: some View {
        VStack {
            NavigationLink {
                SignUpView()
            } label: {
                Text("Get Started!")
                    .modifier(SignUpButtonStyle(opacity: 0.75))
            }
            
            NavigationLink {
                SignUpReturningView()
            } label: {
                Text("Already Use LocalPass?")
                    .modifier(SignUpButtonStyle(opacity: 0.5))
            }
            
            Button {
                showAboutView.toggle()
            } label: {
                Text("About LocalPass")
                    .modifier(SignUpButtonStyle(opacity: 0.25))
            }
            .fullScreenCover(isPresented: $showAboutView) {
                AboutView()
            }
        }
    }
}

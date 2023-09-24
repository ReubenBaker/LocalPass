//
//  NotSignedUpView.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 24/09/2023.
//

import SwiftUI

struct NotSignedUpView: View {
    var body: some View {
        VStack {
            Text("You haven't used the LocalPass app yet! 😢\n\nFollow the setup instructions there and then come back! 🤩")
            
            Image("AppIconImageRoundedCorners")
                .LogoIconStyle()
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .padding(.top)
        .font(.headline)
        .modifier(SignUpViewStyle())
    }
}

struct NotSignedUpView_Previews: PreviewProvider {
    static var previews: some View {
        NotSignedUpView()
    }
}

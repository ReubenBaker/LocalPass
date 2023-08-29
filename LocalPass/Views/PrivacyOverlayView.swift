//
//  PrivacyOverlayView.swift
//  LocalPass
//
//  Created by Reuben on 25/08/2023.
//

import SwiftUI

struct PrivacyOverlayView: View {
    
    @EnvironmentObject private var privacyOverlayViewModel: PrivacyOverlayViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - privacyOverlayViewModel.privacyOverlaySize)

            RoundedRectangle(cornerRadius: 20)
                .frame(width: UIScreen.main.bounds.width, height: privacyOverlayViewModel.privacyOverlaySize)
                .background(.ultraThinMaterial).ignoresSafeArea()
        }
    }
}

// Preview
struct PrivacyOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var privacyOverlayViewModel = PrivacyOverlayViewModel()
        
        PrivacyOverlayView()
            .environmentObject(privacyOverlayViewModel)
    }
}

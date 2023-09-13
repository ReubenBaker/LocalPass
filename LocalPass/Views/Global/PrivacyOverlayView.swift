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
        ZStack {
            if privacyOverlayViewModel.showPrivacyOverlay {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.ultraThinMaterial).ignoresSafeArea()
            }
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

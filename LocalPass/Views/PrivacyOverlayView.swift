//
//  PrivacyOverlayView.swift
//  LocalPass
//
//  Created by Reuben on 25/08/2023.
//

import SwiftUI

struct PrivacyOverlayView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - mainViewModel.privacyOverlaySize)

            RoundedRectangle(cornerRadius: 20)
                .frame(width: UIScreen.main.bounds.width, height: mainViewModel.privacyOverlaySize)
                .background(.ultraThinMaterial).ignoresSafeArea()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .inactive || newPhase == .background {
                withAnimation(.easeInOut(duration: 0.3)) {
                    mainViewModel.privacyOverlaySize = UIScreen.main.bounds.height
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    mainViewModel.privacyOverlaySize = 0
                }
            }
        }
    }
}

struct PrivacyOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var mainViewModel = MainViewModel()
        
        PrivacyOverlayView()
            .environmentObject(mainViewModel)
    }
}

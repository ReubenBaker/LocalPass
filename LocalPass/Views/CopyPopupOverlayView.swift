//
//  CopyPopupOverlayView.swift
//  LocalPass
//
//  Created by Reuben on 25/08/2023.
//

import SwiftUI

struct CopyPopupOverlayView: View {
    
    @EnvironmentObject private var copyPopupOverlayViewModel: CopyPopupOverlayViewModel
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: copyPopupOverlayViewModel.showCopyPopupOverlay ? 55 : 15)
            
            ZStack {
                Capsule()
                  
                HStack(alignment: .center) {
                    Text("Copied")
                        .foregroundColor(.primary.opacity(copyPopupOverlayViewModel.showCopyPopupOverlay ? 1 : 0))
                        .font(.headline)
                }
            }
            .frame(width: copyPopupOverlayViewModel.showCopyPopupOverlay ? 175 : 100, height: copyPopupOverlayViewModel.showCopyPopupOverlay ? 50 : 20)
            .background(Color("AccentColor").opacity(copyPopupOverlayViewModel.showCopyPopupOverlay ? 1 : 0))
            .foregroundStyle(.ultraThickMaterial.opacity(copyPopupOverlayViewModel.showCopyPopupOverlay ? 1 : 0))
            .cornerRadius(44)
            
            Spacer()
        }
        .ignoresSafeArea()
    }
}

// Preview
struct CopyPopupOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var copyPopupOverlayViewModel = CopyPopupOverlayViewModel()
        
        CopyPopupOverlayView()
            .environmentObject(copyPopupOverlayViewModel)
    }
}

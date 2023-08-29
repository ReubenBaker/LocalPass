//
//  PrivacyOverlayViewModel.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import Foundation
import SwiftUI

class PrivacyOverlayViewModel: ObservableObject {
    @Published var privacyOverlaySize: CGFloat = 0
    
    @Published var showPrivacyOverlay: Bool = false {
        didSet {
            if showPrivacyOverlay {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.privacyOverlaySize = UIScreen.main.bounds.height
                }
            } else {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.privacyOverlaySize = 0
                }
            }
        }
    }
}

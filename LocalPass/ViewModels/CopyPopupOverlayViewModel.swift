//
//  CopyPopupOverlayViewModel.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import Foundation
import SwiftUI

class CopyPopupOverlayViewModel: ObservableObject {
    @Published var showCopyPopupOverlay: Bool = false
    
    func displayCopyPopupOverlay() {
        DispatchQueue.main.async {
            withAnimation(.easeInOut) {
                self.showCopyPopupOverlay = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut) {
                    self.showCopyPopupOverlay = false
                }
            }
        }
    }
}

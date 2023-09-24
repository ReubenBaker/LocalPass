//
//  SignUpButtonStyle.swift
//  LocalPass
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI

struct SignUpButtonStyle: ViewModifier {
    let opacity: CGFloat
    
    init(opacity: CGFloat) {
        self.opacity = opacity
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.ultraThickMaterial.opacity(opacity))
            .cornerRadius(10)
    }
}

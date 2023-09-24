//
//  DeleteButtonStyle.swift
//  LocalPass
//
//  Created by Reuben on 17/09/2023.
//

import Foundation
import SwiftUI

struct ProminentButtonStyle: ButtonStyle {
    let color: Color
    
    init(_ color: Color) {
        self.color = color
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.bold)
            .padding()
            .foregroundColor(.primary)
            .frame(minWidth: 200)
            .background(color)
            .cornerRadius(10)
            .shadow(radius: 4)
    }
}

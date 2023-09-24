//
//  NoDataButtonStyle.swift
//  LocalPass
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI

struct NoDataButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
            .background(Color("AccentColor"))
            .cornerRadius(10)
            .shadow(radius: 4)
            .padding()
    }
}

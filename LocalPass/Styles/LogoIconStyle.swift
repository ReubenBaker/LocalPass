//
//  LogoIconStyle.swift
//  LocalPass
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI

extension Image {
    func LogoIconStyle(large: Bool = false) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(maxWidth: UIScreen.main.bounds.width / (large ? 2 : 6))
            .frame(maxWidth: large ? .infinity : 125, maxHeight: large ? .infinity : 125)
            .padding()
    }
}

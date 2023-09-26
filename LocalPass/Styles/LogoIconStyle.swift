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
            .frame(maxWidth: large ? 250 : 75, maxHeight: large ? 250 : 75)
            .padding()
    }
}

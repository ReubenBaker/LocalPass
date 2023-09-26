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
            .frame(maxWidth: large ? UIScreen.main.bounds.width / 2 : 75, maxHeight: large ? UIScreen.main.bounds.width / 2 : 75)
            .padding()
    }
}

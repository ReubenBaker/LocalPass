//
//  ListItemImageStyle.swift
//  LocalPass
//
//  Created by Reuben on 21/09/2023.
//

import Foundation
import SwiftUI

extension Image {
    func ListItemImageStyle() -> some View {
        self
            .resizable()
            .scaledToFit()
            .foregroundColor(Color("AccentColor"))
    }
}

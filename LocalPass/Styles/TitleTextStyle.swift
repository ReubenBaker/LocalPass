//
//  TitleTextStyle.swift
//  LocalPass
//
//  Created by Reuben on 17/09/2023.
//

import Foundation
import SwiftUI

struct TitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .fontWeight(.semibold)
            .lineLimit(1)
            .padding(.horizontal, 70)
    }
}

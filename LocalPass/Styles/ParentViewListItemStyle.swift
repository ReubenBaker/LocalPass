//
//  ParentViewListItemStyle.swift
//  LocalPass
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI

struct ParentViewListItemStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(PrivacyOverlayView())
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
    }
}

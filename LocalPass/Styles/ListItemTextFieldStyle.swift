//
//  ListItemTextFieldStyle.swift
//  LocalPass
//
//  Created by Reuben on 22/09/2023.
//

import Foundation
import SwiftUI

struct ListItemTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxHeight: .infinity)
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
            .tint(.primary)
    }
}

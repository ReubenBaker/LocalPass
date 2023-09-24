//
//  TextEditorStyle.swift
//  LocalPass
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI

struct TextEditorStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .font(.headline)
            .padding()
            .tint(.primary)
            .scrollContentBackground(.hidden)
    }
}

//
//  RawTextFieldInputStyle.swift
//  LocalPass
//
//  Created by Reuben on 21/09/2023.
//

import Foundation
import SwiftUI

struct RawTextFieldInputStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
    }
}

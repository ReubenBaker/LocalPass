//
//  SignUpViewStyle.swift
//  LocalPass
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI

struct SignUpViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color("AppThemeColor"))
    }
}

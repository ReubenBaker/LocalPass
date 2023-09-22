//
//  AuthenticationTextFieldStyle.swift
//  LocalPass
//
//  Created by Reuben on 22/09/2023.
//

import Foundation
import SwiftUI

struct AuthenticationTextFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .fontWeight(.semibold)
            .multilineTextAlignment(.leading)
            .tint(.primary)
            .background(Color("GeneralColor"))
            .cornerRadius(10)
            .padding(.bottom)
    }
}

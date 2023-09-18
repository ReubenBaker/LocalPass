//
//  ListItemStyle.swift
//  LocalPass
//
//  Created by Reuben on 18/09/2023.
//

import Foundation
import SwiftUI

struct ListItemStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.horizontal)
            .foregroundColor(.primary)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(Color("GeneralColor"))
            .cornerRadius(10)
    }
}

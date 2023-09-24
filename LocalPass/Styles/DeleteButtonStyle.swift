//
//  DeleteButtonStyle.swift
//  LocalPass
//
//  Created by Reuben on 17/09/2023.
//

import Foundation
import SwiftUI

struct DeleteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .foregroundColor(.primary)
            .frame(minWidth: 150)
            .background(.red)
            .cornerRadius(10)
            .shadow(radius: 4)
    }
}

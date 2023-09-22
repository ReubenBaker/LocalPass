//
//  AccountDetailViewItemStyle.swift
//  LocalPass
//
//  Created by Reuben on 17/09/2023.
//

import Foundation
import SwiftUI

struct AccountDetailViewItemStyle: ViewModifier {
    let fieldClicked: Bool
    
    init(fieldClicked: Bool = true) {
        self.fieldClicked = fieldClicked
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 10)
            .padding(.horizontal)
            .frame(height: 50)
            .frame(minWidth: 150, maxWidth: fieldClicked ? .infinity : nil)
            .foregroundColor(.primary)
            .background(Color("GeneralColor"))
            .cornerRadius(10)
    }
}

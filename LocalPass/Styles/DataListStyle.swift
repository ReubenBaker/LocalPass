//
//  DataListStyle.swift
//  LocalPass
//
//  Created by Reuben on 24/09/2023.
//

import Foundation
import SwiftUI

struct DataListStyle: ViewModifier {
    let type: String
    
    init(type: String) {
        self.type = type
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .environment(\.defaultMinListRowHeight, 0)
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .navigationTitle(type)
    }
}

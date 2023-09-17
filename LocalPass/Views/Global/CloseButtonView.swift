//
//  CloseButtonView.swift
//  LocalPass
//
//  Created by Reuben on 17/09/2023.
//

import SwiftUI

struct CloseButtonView: View {
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button {
           dismiss()
       } label: {
           Image(systemName: "xmark")
               .font(.headline)
               .padding()
               .foregroundColor(Color("AccentColor"))
               .background(.thickMaterial)
               .cornerRadius(10)
               .shadow(radius: 4)
               .padding()
       }
    }
}

struct CloseButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CloseButtonView()
    }
}

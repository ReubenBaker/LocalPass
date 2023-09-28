//
//  PasswordGeneratorView.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import SwiftUI

struct PasswordGeneratorView: View {
    
    @Binding var password: String
    @State var characterCount: Int = 16
    @State var numericalCount: Int = 4
    @State var specialCount: Int = 4
    
    var body: some View {
        VStack {
            Text(password == "" ? "Password" : password)
                .font(.title)
                .lineLimit(1)
                .padding(.bottom)
            
            Stepper("Character Count: \(characterCount)", value: $characterCount, in: 8...32)
            
            Stepper("Number Count: \(numericalCount)", value: $numericalCount, in: 0...characterCount - specialCount)
            
            Stepper("Special Count: \(specialCount)", value: $specialCount, in: 0...characterCount - numericalCount)
            
            Button("Generate") {
                withAnimation {
                    password = PasswordGeneratorDataService().generatePassword(
                        characterCount: characterCount,
                        numericalCount: numericalCount,
                        specialCount: specialCount
                    )
                }
            }
            .buttonStyle(ProminentButtonStyle(.green))
            .padding(.top)
            
            Spacer()
            
            CloseButtonView()
        }
        .padding()
    }
}

// Preview
struct PasswordGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        @StateObject var accountsViewModel = AccountsViewModel()
        @State var password = "Password"
        
        PasswordGeneratorView(password: $password)
            .environmentObject(accountsViewModel)
    }
}

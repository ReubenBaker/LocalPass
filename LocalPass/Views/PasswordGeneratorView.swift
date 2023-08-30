//
//  PasswordGeneratorView.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import SwiftUI

struct PasswordGeneratorView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    @Binding var password: String
    @State var characterCount: Int = 16
    @State var numericalCount: Int = 4
    @State var specialCount: Int = 4
    @State var hasNumbers: Bool = true
    @State var hasSpecials: Bool = true
    
    var body: some View {
        ScrollView {
            VStack {
                Text(password == "" ? "Password" : password)
                    .font(.title)
                    .lineLimit(1)
                
                Stepper("Character Count: \(characterCount)", value: $characterCount, in: 8...32)
                
                Stepper("Number Count: \(numericalCount)", value: $numericalCount, in: 0...characterCount - specialCount)
                
                Stepper("Special Count: \(specialCount)", value: $specialCount, in: 0...characterCount - numericalCount)
                
                Button {
                    withAnimation {
                        password = PasswordGeneratorDataService().generatePassword(
                            characterCount: characterCount,
                            numericalCount: numericalCount,
                            specialCount: specialCount
                        )
                    }
                } label: {
                    Text("Generate")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.primary)
                        .background(.green)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                        .padding()
                }

            }
            .padding()
        }
        .overlay(closeButton, alignment: .bottom)
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

// Views
extension PasswordGeneratorView {
    private var closeButton: some View {
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

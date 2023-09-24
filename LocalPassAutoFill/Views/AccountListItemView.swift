//
//  AccountListItemView.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 24/09/2023.
//

import SwiftUI

struct AccountListItemView: View {
    
    var autoFill: (() -> Void)?
    @Binding var account: Account
    @EnvironmentObject private var credentialProviderViewModel: CredentialProviderViewModel
    @State private var otpValue: String = ""
    @State private var otpTimeLeft: Int = 0
    @State private var otpColor: Color = .green
    @State private var otpFlashing: Bool = false
    
    var body: some View {
        accountListItem
    }
}

// Functions
extension AccountListItemView {
    private func updateTimeLeft() {
        let timeSince1970 = Int(Date().timeIntervalSince1970)
        let nextInterval = (timeSince1970 / 30) * 30
        otpTimeLeft = 30 - abs(nextInterval - timeSince1970)
    }
    
    private func startTOTPTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            updateTimeLeft()
            
            if otpTimeLeft == 30 {
                generateTOTP()
            }
        }
    }
    
    private func generateTOTP() {
        if let secret = account.otpSecret {
            otpValue = TOTPGeneratorDataService.TOTP(secret)
        }
    }
}

// Views
extension AccountListItemView {
    private var accountListItem: some View {
        Button {
            credentialProviderViewModel.username = account.username
            credentialProviderViewModel.password = account.password
            
            self.autoFill?()
        } label: {
            HStack {
                if let url = account.url {
                    if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
                        if sharedUserDefaults.bool(forKey: "showFavicons") {
                            FaviconImageView(url: url)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .ListItemImageStyle()
                        }
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .ListItemImageStyle()
                }
                
                Text(account.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if account.otpSecret != nil {
                    Text(otpValue)
                        .fontWeight(.semibold)
                        .onAppear {
                            updateTimeLeft()
                            startTOTPTimer()
                            generateTOTP()
                        }
                    
                    ZStack {
                        if !otpFlashing {
                            Circle()
                                .stroke(.gray, lineWidth: 5)
                        }
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(otpTimeLeft - 1) / 30)
                            .stroke(otpColor, lineWidth: 5)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: otpTimeLeft)
                        
                        Text("\(otpTimeLeft)")
                    }
                    .onChange(of: otpTimeLeft) { newValue in
                        withAnimation(.easeInOut) {
                            if newValue <= 5 {
                                otpColor = .red
                                otpFlashing.toggle()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    otpFlashing.toggle()
                                }
                            } else if newValue <= 10 {
                                otpColor = .yellow
                            } else {
                                otpColor = .green
                            }
                        }
                    }
                }
            }
            .modifier(ListItemStyle())
        }
    }
}

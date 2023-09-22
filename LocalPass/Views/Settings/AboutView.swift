//
//  AboutView.swift
//  LocalPass
//
//  Created by Reuben on 05/09/2023.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        let features: [String] = [
            "🔐 Data Encryption:\nAll of your data is always encrypted, using strong AES encryption. Your sensitive information remains indecipherable to anyone without the encryption key",
            "🔑 PBKDF2 Hashing:\nLocalPass employs industry-standard PBKDF2 password hashing algorithms to ensure that your master password is securely transformed into the encryption key, making it virtually impossible for anyone to reverse engineer. The encryption key is also rotated every time you enter your password.",
            "🗒️ Secure Notes:\nIn addition to password management, LocalPass allows you to store secure notes. Personal information, PINs, and other sensitive data are all encrypted, giving you peace of mind.",
            "🔒 Biometric Authentication:\nAccess your data with ease using biometric authentication, ensuring a seamless and secure experience.",
            "🔄 TOTP Support:\nLocalPass supports Time-Based One-Time Passwords (TOTP) for multifactor authentication.",
            "🌐 iCloud Sync (Optional):\nWhile your data is protected by encryption on your device, LocalPass provides the option to sync your data with iCloud between devices for convenience. Only encrypted data is ever stored in iCloud, just like on your device.",
            "📊 No User Data Collection:\nLocalPass is built with a committment to privacy. LocalPass does not collect any personal data whatsoever, and does not talk to any external data servers.",
            "📲 iOS Development Enthusiasts:\nLocalPass is an open-source personal project, created by a Computer Science student. If you are an iOS developer and enjoy using LocalPass, consider exploring the codebase, and submit a pull request to enhance the security and features of LocalPass."
        ]
        
        let plannedFeatures: [String] = [
            "🤖 Password Autofill:\nThis will make logging in to your favourite apps and websites even more convenient!",
            "♻️ Recycle Bin (Optional):\nMistakenly delete something? The recycle bin will help you recover that data securely.",
            "🔔 Password Change Reminders (Optional):\nStay secure with password change reminders at your chosen frequency.",
            "📁 Folders:\nHelp organize your passwords and secure notes with customizable folders.",
            "💳 Secure Storage for Cards and IDs",
            "📱 Enhanced iPad Support"
        ]
        
        ScrollView {
            VStack {
                Text("Why LocalPass?")
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("LocalPass is a forever free, ad free, and open-source solution for managing your passwords, secure notes, and more, with an unwaivering emphasis on data encryption and security. With a range of useful features, LocalPass simplifies your digital life while ensuring your information is kept private and secure.")
                        .font(.headline)
                        .padding(.bottom)
                }
                
                Text("Key Features:")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    ForEach(features, id: \.self) {feature in
                        Text(feature)
                            .padding(.bottom, 4)
                            .font(.headline)
                    }
                }
                
                Text("Coming Soon:")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    ForEach(plannedFeatures, id: \.self) { feature in
                        Text(feature)
                            .padding(.bottom, 4)
                            .font(.headline)
                    }
                }
                
                Text("Thank you for using LocalPass! 🤩")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding(.bottom)
                
                VStack {
                    HStack {
                        Image("GitHub-Logo")
                            .resizable()
                            .scaledToFit()
                        
                        Text("GitHub")
                            .foregroundColor(.white)
                    }
                    .frame(maxHeight: 25)
                    .frame(minWidth: 155)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .onTapGesture {
                        if let url = URL(string: "https://github.com/ReubenBaker/LocalPass") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    HStack {
                        Image("BMC-Logo")
                            .resizable()
                            .scaledToFit()
                        
                        Text("Buy Me A Coffee")
                            .foregroundColor(.white)
                    }
                    .frame(maxHeight: 25)
                    .frame(minWidth: 155)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .onTapGesture {
                        if let url = URL(string: "https://buymeacoffee.com/localpass") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    HStack {
                        Image("X-Logo")
                            .resizable()
                            .scaledToFit()
                        
                        Text("X")
                            .foregroundColor(.white)
                    }
                    .frame(maxHeight: 25)
                    .frame(minWidth: 155)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .onTapGesture {
                        if let url = URL(string: "https://twitter.com/localpassapp") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "text.book.closed")
                            .resizable()
                            .scaledToFit()
                        
                        Text("License")
                            .foregroundColor(.white)
                    }
                    .frame(maxHeight: 25)
                    .frame(minWidth: 155)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .onTapGesture {
                        if let url = URL(string: "https://github.com/ReubenBaker/LocalPass/blob/main/LICENSE") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(Color("AppThemeColor"))
        .foregroundColor(.white)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

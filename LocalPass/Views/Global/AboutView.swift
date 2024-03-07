//
//  AboutView.swift
//  LocalPass
//
//  Created by Reuben on 05/09/2023.
//

import SwiftUI

struct AboutView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        let features: [[String]] = [
            ["🔐 Data Encryption:\n", "All of your data is always encrypted, using strong AES encryption. Your sensitive information remains indecipherable to anyone without the encryption key.\n"],
            ["🔑 PBKDF2 Key Derivation:\n", "LocalPass employs industry-standard PBKDF2 key derivation with 100k iterations, to ensure that your master password is securely transformed into the encryption key, making it virtually impossible for anyone to reverse engineer. The encryption key is also rotated every time you enter your password.\n"],
            ["🗒️ Secure Notes:\n", "In addition to password management, LocalPass allows you to store secure notes. Personal information, and other sensitive data are all encrypted, giving you peace of mind.\n"],
            ["🔒 Biometric Authentication:\n", "Access your data with ease using biometric authentication, ensuring a seamless and secure experience.\n"],
            ["🤖 Autofill Support:\n", "LocalPass supports credential autofilling in safari and your favourite apps! Just make sure to enable it in your device's settings under:\n>'Passwords'\n>'Password Options'\n>'Allow Filling From:' LocalPass!\n"],
            ["🔄 TOTP Support:\n", "LocalPass supports Time-Based One-Time Passwords (TOTP) for multifactor authentication.\n"],
            ["📊 No User Data Collection:\n", "LocalPass is built with a committment to privacy. LocalPass does not collect any personal data whatsoever, and does not talk to any external data servers. It only ever talks to the internet if you have account icons or iCloud sync enabled.\n"],
            ["📲 iOS Development Enthusiasts:\n", "LocalPass is an open-source personal project, created by a Computer Science student. If you are an iOS developer and enjoy using LocalPass, consider exploring the codebase, and submit a pull request to enhance the security and features of LocalPass.\n"]
        ]
        
        let plannedFeatures: [[String]] = [
            ["🌐 iCloud Sync (Optional):\n", "While your data is protected by encryption on your device, LocalPass will provide the option to sync your encrypted data with iCloud between devices for convenience. Only encrypted data will ever be stored in iCloud, just like on your device.\n"],
            ["♻️ Recycle Bin (Optional):\n", "Mistakenly delete something? The recycle bin will help you recover that data securely.\n"],
            ["🔔 Password Change Reminders (Optional):\n", "Stay secure with password change reminders at your chosen frequency.\n"],
            ["📁 Folders:\n", "Help organize your passwords and secure notes with customizable folders.\n"],
            ["💳 Secure Storage for Credit Cards and IDs:\n", "Store credit cards, ID numbers, or whatever you'd like! This will also include support for autofilling credit card details.\n"],
            ["📱 Enhanced iPad Support:\n", "LocalPass v1.0 has been designed with the iPhone in mind, however better support for iPad (and Mac running as an iPad app) is coming! No native MacOS app is currently planned.\n"]
        ]
        
        ScrollView {
            VStack {
                Text("Why LocalPass?")
                    .font(.title)
                    .fontWeight(.heavy)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    Text("LocalPass is a forever free, ad free, and open-source solution for managing your passwords, secure notes, and more, with an unwaivering emphasis on data encryption and security. With a range of useful features, LocalPass simplifies your digital life while ensuring your information is kept private and secure.")
                        .font(.callout)
                        .padding(.bottom)
                }
                
                Text("Key Features:")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    ForEach(features, id: \.self) { innerArray in
                        VStack(alignment: .leading) {
                            Text(innerArray[0])
                                .font(.callout)
                                .fontWeight(.heavy)
                            
                            if innerArray[1] != "" {
                                Text(innerArray[1])
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                
                Text("Coming Soon:")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding(.bottom)
                
                VStack(alignment: .leading) {
                    ForEach(plannedFeatures, id: \.self) { innerArray in
                        VStack(alignment: .leading) {
                            Text(innerArray[0])
                                .font(.callout)
                                .fontWeight(.heavy)
                            
                            if innerArray[1] != "" {
                                Text(innerArray[1])
                                    .font(.subheadline)
                            }
                        }
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
                        
                        Spacer()
                        
                        Text("GitHub")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 170, maxHeight: 25)
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
                        
                        Spacer()
                        
                        Text("Buy Me A Coffee")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 170, maxHeight: 25)
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
                        
                        Spacer()
                        
                        Text("X")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 170, maxHeight: 25)
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
                        
                        Spacer()
                        
                        Text("License")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .frame(maxWidth: 170, maxHeight: 25)
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(10)
                    .onTapGesture {
                        if let url = URL(string: "https://github.com/ReubenBaker/LocalPass/blob/main/LICENSE") {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                
                Text("Version: LocalPass v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                    .opacity(0.25)
                
                Spacer()
                    .frame(height: 70)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .background(Color("AppThemeColor"))
        .foregroundColor(.white)
        .overlay(alignment: .bottom) {
            CloseButtonView()
        }
        .onChange(of: scenePhase) { phase in
            if phase != .active && LocalPassApp.settings.lockVaultOnBackground {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    dismiss()
                }
            }
        }
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}

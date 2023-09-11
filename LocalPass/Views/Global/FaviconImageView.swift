//
//  FaviconImageView.swift
//  LocalPass
//
//  Created by Reuben on 11/09/2023.
//

import SwiftUI

struct FaviconImageView: View {
    let url: String
    
    @State private var faviconURL: String?
    
    var body: some View {
        Group {
            if let faviconURL = faviconURL,
               let url = URL(string: faviconURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        accountIcon
                    default:
                        accountIcon
                    }
                }
            } else {
                accountIcon
            }
        }
        .onAppear {
            let url = addHTTPSPrefixIfNeeded(url)
            
            Favicon(url).faviconURL(.xxl) { result in
                if case .success(let url) = result {
                    faviconURL = url
                }
            }
        }
    }
}

struct FaviconImageView_Previews: PreviewProvider {
    static var previews: some View {
        FaviconImageView(url: "apple.com")
    }
}

// Functions
extension FaviconImageView {
    private func addHTTPSPrefixIfNeeded(_ urlString: String) -> String {
        if urlString.lowercased().hasPrefix("http://") || urlString.lowercased().hasPrefix("https://") {
            return urlString
        } else {
            return "https://" + urlString
        }
    }
}

// Views
extension FaviconImageView {
    private var accountIcon: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(Color("AccentColor"))
    }
}

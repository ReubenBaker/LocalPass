//
//  FaviconImageView.swift
//  LocalPass
//
//  Created by Reuben on 11/09/2023.
//

import SwiftUI

struct FaviconImageView: View {

    @StateObject private var faviconImageViewModel = FaviconImageViewModel()
    @State private var image: UIImage?
    @State private var isLoading: Bool = false
    let url: String
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            } else {
                accountIcon
            }
        }
        .onAppear {
            let url = faviconImageViewModel.addHTTPSPrefixIfNeeded(url)
            
            if let cachedImage = faviconImageViewModel.getCachedImage(for: url) {
                image = cachedImage
            } else {
                isLoading = true
                
                Favicon(url).faviconURL(.xxl) { result in
                    if case .success(let urlString) = result {
                        if let imageUrl = URL(string: urlString) {
                            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                                if let data = data, let fetchedImage = UIImage(data: data) {
                                    if faviconImageViewModel.isDefaultFavicon(fetchedImage) {
                                        image = nil
                                    } else {
                                        faviconImageViewModel.cacheImage(fetchedImage, for: url)
                                        
                                        DispatchQueue.main.async {
                                            image = fetchedImage
                                        }
                                    }
                                    
                                    isLoading = false
                                }
                            }.resume()
                        }
                    } else {
                        isLoading = false
                    }
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

// Views
extension FaviconImageView {
    private var accountIcon: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFit()
            .foregroundColor(Color("AccentColor"))
    }
}

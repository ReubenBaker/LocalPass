//
//  FaviconImageView.swift
//  LocalPass
//
//  Created by Reuben on 11/09/2023.
//

import SwiftUI

struct FaviconImageView: View {
    let url: String
    
    @State private var image: UIImage?
    @State private var isLoading: Bool = false
    
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
            let url = addHTTPSPrefixIfNeeded(url)
            
            if let cachedImage = getCachedImage(for: url) {
                image = cachedImage
            } else {
                isLoading = true
                
                Favicon(url).faviconURL(.xxl) { result in
                    if case .success(let urlString) = result {
                        if let imageUrl = URL(string: urlString) {
                            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                                if let data = data, let fetchedImage = UIImage(data: data) {
                                    if isDefaultFavicon(fetchedImage) {
                                        image = nil
                                    } else {
                                        cacheImage(fetchedImage, for: url)
                                        
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

// Functions
extension FaviconImageView {
    private func addHTTPSPrefixIfNeeded(_ urlString: String) -> String {
        if urlString.lowercased().hasPrefix("http://") || urlString.lowercased().hasPrefix("https://") {
            return urlString
        } else {
            return "https://" + urlString
        }
    }
    
    private func isDefaultFavicon(_ image: UIImage) -> Bool {
        let defaultFaviconSize = CGSize(width: 16, height: 16)
        
        return image.size == defaultFaviconSize
    }
    
    private func getCachedImage(for key: String) -> UIImage? {
        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = cacheDirectory.appendingPathComponent(key.replacingOccurrences(of: "/", with: "_"))
            
            if let data = try? Data(contentsOf: fileURL),
               let cachedImage = UIImage(data: data) {
                return cachedImage
            }
        }
        
        return nil
    }
    
    private func cacheImage(_ image: UIImage, for key: String) {
        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = cacheDirectory.appendingPathComponent(key.replacingOccurrences(of: "/", with: "_"))

            if let data = image.pngData() {
                do {
                    try data.write(to: fileURL)
                } catch {
                    print("Error writing to cache: \(error)")
                }
            }
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

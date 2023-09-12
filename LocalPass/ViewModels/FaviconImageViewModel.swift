//
//  FaviconImageViewModel.swift
//  LocalPass
//
//  Created by Reuben on 12/09/2023.
//

import Foundation
import SwiftUI

class FaviconImageViewModel: ObservableObject {
    func addHTTPSPrefixIfNeeded(_ urlString: String) -> String {
        if urlString.lowercased().hasPrefix("http://") || urlString.lowercased().hasPrefix("https://") {
            return urlString
        } else {
            return "https://" + urlString
        }
    }
    
    func isDefaultFavicon(_ image: UIImage) -> Bool {
        let defaultFaviconSize = CGSize(width: 16, height: 16)
        
        return image.size == defaultFaviconSize
    }
    
    func getCachedImage(for key: String) -> UIImage? {
        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = cacheDirectory.appendingPathComponent(key.replacingOccurrences(of: "[^a-zA-Z0-9]+", with: "", options: .regularExpression))
            
            if let data = try? Data(contentsOf: fileURL),
               let cachedImage = UIImage(data: data) {
                return cachedImage
            }
        }
        
        return nil
    }
    
    func cacheImage(_ image: UIImage, for key: String) {
        if let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
            let fileURL = cacheDirectory.appendingPathComponent(key.replacingOccurrences(of: "[^a-zA-Z0-9]+", with: "", options: .regularExpression))

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

//
//  FaviconModel.swift
//  LocalPass
//
//  Created by Reuben on 11/09/2023.
//

import Foundation

struct Favicon {
    enum Size: Int, CaseIterable {
        case s = 16, m = 32, l = 64, xl = 128, xxl = 256, xxxl = 512
    }
    
    private let domain: String
    
    init(_ domain: String) {
        self.domain = domain
    }
    
    func faviconURL(_ size: Size, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: domain) else {
            let error = NSError(domain: "FaviconErrorDomain", code: 1, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (_, response, error) in
            if let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) {
                let faviconURL = "https://www.google.com/s2/favicons?sz=\(size.rawValue)&domain=\(self.domain)"
                completion(.success(faviconURL))
            }
            else {
                completion(.failure(error ?? NSError()))
            }
        }
        .resume()
    }
}

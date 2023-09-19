//
//  TOTPGeneratorDataService.swift
//  LocalPass
//
//  Created by Reuben on 30/08/2023.
//

import Foundation
import CryptoKit

class TOTPGeneratorDataService {
    static func TOTP(secret: String, period: TimeInterval = TimeInterval(30), digits: Int = 6) -> String {
        if let data = base32Decode(secret) {
            let counter = UInt64(Date().timeIntervalSince1970 / period)
            let counterBytes = (0..<8).reversed().map { UInt8(counter >> (8 * $0) & 0xff) }
            let hash = HMAC<Insecure.SHA1>.authenticationCode(for: counterBytes, using: SymmetricKey(data: data))
            let offset = Int(hash.suffix(1)[0] & 0x0f)
            let hash32 = hash
                .dropFirst(offset)
                .prefix(4)
                .reduce(0, { ($0 << 8) | UInt32($1) })
            let hash31 = hash32 & 0x7FFF_FFFF
            let pad = String(repeating: "0", count: digits)
            return String((pad + String(hash31)).suffix(digits))
        }
        return "Invalid Key!"
    }
    
    static func base32Decode(_ encodedString: String) -> Data? {
        let base32Alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
        let base32Map = Dictionary(uniqueKeysWithValues: base32Alphabet.enumerated().map { ($1, $0) })
        var encoded = encodedString.uppercased()
        var paddingCount = 0
        
        while encoded.hasSuffix("=") {
            paddingCount += 1
            encoded = String(encoded.dropLast())
        }
        
        var bits: UInt64 = 0
        var bitCount: UInt8 = 0
        var decodedData = Data()
        
        for char in encoded {
            guard let charValue = base32Map[char] else {
                return nil
            }
            
            bits = (bits << 5) | UInt64(charValue)
            bitCount += 5
            
            if bitCount >= 8 {
                let byte = UInt8((bits >> (bitCount - 8)) & 0xFF)
                decodedData.append(byte)
                bitCount -= 8
            }
        }
        
        if paddingCount > 0 && bitCount > 0 {
            return nil
        }
        
        return decodedData
    }
}

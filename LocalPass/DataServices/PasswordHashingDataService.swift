//
//  PasswordHashingDataService.swift
//  LocalPass
//
//  Created by Reuben on 06/09/2023.
//

import Foundation
import CryptoKit
import CommonCrypto

class PasswordHashingDataService {
    private var sessionKey: SymmetricKey?
    
    func generateRandomSalt() -> Data? {
        var salt = [UInt8](repeating: 0, count: 16)
        let status = SecRandomCopyBytes(kSecRandomDefault, salt.count, &salt)
        
        if status == errSecSuccess {
            return Data(salt)
        } else {
            return nil
        }
    }
    
    func deriveKey(password: String, salt: Data) -> SymmetricKey? {
        let passwordData = Data(password.utf8)
        var derivedKey = [UInt8](repeating: 0, count: 32)
        
        let result = salt.withUnsafeBytes { saltBytes in
            passwordData.withUnsafeBytes { passwordBytes in
                CCKeyDerivationPBKDF(
                    CCPBKDFAlgorithm(kCCPBKDF2),
                    passwordBytes.baseAddress?.assumingMemoryBound(to: Int8.self),
                    passwordData.count,
                    saltBytes.baseAddress?.assumingMemoryBound(to: UInt8.self),
                    salt.count,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    10000,
                    &derivedKey,
                    derivedKey.count
                )
            }
        }
        
        if result == kCCSuccess {
            return SymmetricKey(data: Data(derivedKey))
        } else {
            return nil
        }
    }
    
    func calculateChecksum(data: Data) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        data.withUnsafeBytes { dataBytes in
            _ = CC_SHA256(dataBytes.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return Data(digest)
    }
    
    func encryptBlob(blob: String, password: String) -> Data? {
        guard let salt = generateRandomSalt(),
            let key = deriveKey(password: password, salt: salt),
            let data = blob.data(using: .utf8) else {
          return nil
        }
        
        let combined = salt + data
        let checksum = calculateChecksum(data: combined)
        
        if let sealedBox = try? AES.GCM.seal(data + checksum, using: key) {
            setSessionKey(key: key)
            if let combined = sealedBox.combined {
                return salt + combined
            }
        } else {
            return nil
        }
        
        return nil
    }
    
    func decryptBlob(blob: Data, password: String) -> String? {
        let saltSize = 16
        let salt = blob.prefix(saltSize)
        
        guard let key = deriveKey(password: password, salt: salt) else {
            return nil
        }
        
        let encryptedData = blob.dropFirst(saltSize)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            let appendedChecksum = decryptedData.suffix(Int(CC_SHA256_DIGEST_LENGTH))
            print("AppendedChecksum: \(appendedChecksum.base64EncodedString())")
            let expectedChecksum = calculateChecksum(data: salt + decryptedData.dropLast(Int(CC_SHA256_DIGEST_LENGTH)))
            print("ExpectedChecksum: \(expectedChecksum.base64EncodedString())")
            
            if appendedChecksum.base64EncodedData() == expectedChecksum.base64EncodedData() {
                return String(data: decryptedData.dropLast(Int(CC_SHA256_DIGEST_LENGTH)), encoding: .utf8)
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    func decryptBlob(blob: Data, key: SymmetricKey) -> String? {
        let saltSize = 16
        let salt = blob.prefix(saltSize)
        
        let encryptedData = blob.dropFirst(saltSize)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            let appendedChecksum = decryptedData.suffix(Int(CC_SHA256_DIGEST_LENGTH))
            print("AppendedChecksum: \(appendedChecksum.base64EncodedString())")
            let expectedChecksum = calculateChecksum(data: salt + decryptedData.dropLast(Int(CC_SHA256_DIGEST_LENGTH)))
            print("ExpectedChecksum: \(expectedChecksum.base64EncodedString())")
            
            if appendedChecksum.base64EncodedData() == expectedChecksum.base64EncodedData() {
                return String(data: decryptedData.dropLast(Int(CC_SHA256_DIGEST_LENGTH)), encoding: .utf8)
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    func setSessionKey(key: SymmetricKey) {
        clearSessionKey()
        
        key.withUnsafeBytes { keyBytes in
            self.sessionKey = SymmetricKey(data: Data(keyBytes))
        }
    }
    
    func getSessionKey() -> SymmetricKey? {
        return self.sessionKey
    }
    
    func clearSessionKey() {
        guard let sessionKey = self.sessionKey else {
            return
        }
        
        let randomPassword = Data((0..<sessionKey.bitCount/8).map { _ in UInt8.random(in: 0...255) })
        
        if let salt = generateRandomSalt() {
            self.sessionKey = deriveKey(password: randomPassword.base64EncodedString(), salt: salt)
        }
        
        self.sessionKey = nil
    }
    
    func test() {
        let blob = "Data to be encrypted"
        let password = "Password123"
        
        for _ in 0...2 {
            if let encryptedBlob = encryptBlob(blob: blob, password: password) {
                print("Blob: \(blob)")
                print("Session Key: \(String(describing: getSessionKey()?.withUnsafeBytes{ Data($0) }.base64EncodedString()))")
                print("Encrypted String: \(encryptedBlob.base64EncodedString())")
                
                if let key = getSessionKey() {
                    if let decryptedBlob = decryptBlob(blob: encryptedBlob, key: key) {
                        print("Decrypted String: \(decryptedBlob)")
                    }
                }
            }
        }
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

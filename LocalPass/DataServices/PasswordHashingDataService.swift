//
//  PasswordHashingDataService.swift
//  LocalPass
//
//  Created by Reuben on 06/09/2023.
//

import Foundation
import CryptoKit
import CommonCrypto

/**
 A utility class for secure encryption and decryption of data using a password-based and session-based key approach with data integrity checks.
 
 # Overview:
 
 The `PasswordHashingDataService` class provides methods for securely encrypting and decrypting data, ensuring data integrity through checksums. It uses the following steps:
 
 1. **Salt Generation**: A random salt is generated for each derived key.
 
 2. **Key Derivation**: The random salt, along with the users password is used to derive a unique encryption key using PBKDF2 with HMAC-SHA256.
 
 3. **Encryption**:
    - Data is prepared by converting it into binary form (UTF-8 encoding) and prepending the salt.
    - A checksum of the combined binary data (salt + data) is calculated using SHA-256.
    - AES-GCM encryption is applied to the combined binary data, producing an encrypted data blob.
 
 4. **Decryption**:
    - The salt is extracted from the beginning of the data blob.
    - If using a password, the encryption key is derived from the salt + password.
    - If using the session key, the session key is used for the decryption.
    - The encrypted data is then decrypted using the given key.
    - A checksum is calculated based on the extracted salt + decrypted data to verify it matches the checksum from the end of the decrypted data blob.
 
 5. **Session Key Handling**: The class also provides methods for managing a session key. Although this will updated in a later version to either use the secure enclave or Apple's Keychain Services.
 
 # Usage:
 
 1. Initialize an instance of `PasswordHashingDataService`.
 
 2. Encrypt sensitive data using the `encryptBlob` method, providing the data and the password.
 
 3. Store the encrypted data.
 
 4. When data access is needed, decrypt it using the `decryptBlob` method with the session key, or on app startup using the password.
 
 5. After decryption has taken place on app startup, generate a new session key and re-encrypt the data to make sure the key is refreshed each session.
 
 This process ensures that data remains confidential and tamper-resistant during storage or transmission. If the password is incorrect or if the data has been tampered with, the decryption will fail, providing an additional layer of security.
 
 # Example:
 ```swift
 let blob = "Data to be encrypted"
 let password = "Password123"
 let service = PasswordHashingDataService()
 
 if let encryptedBlob = service.encryptBlob(blob: blob, password: password) {
    // Store or transmit the encryptedBlob
 
    // To decrypt:
    if let key = service.getSessionKey() {
        if let decryptedBlob = service.decryptBlob(blob: encryptedBlob, key: key) {
            // Handle the decrypted data
        }
    }
 }
 ```
 
 - Version: 1.0
 - Date: September 6, 2023
 */
class PasswordHashingDataService {
    private var sessionKey: SymmetricKey?
    private let saltSize: Int = 16
    private let hashingIterations: UInt32 = 10000
    
    /**
     Generates a random salt for key derivation.
     
     - Returns: A random salt as `Data` or `nil` if the salt generation fails.
     */
    func generateRandomSalt() -> Data? {
        var salt = [UInt8](repeating: 0, count: 16)
        let status = SecRandomCopyBytes(kSecRandomDefault, salt.count, &salt)
        
        if status == errSecSuccess {
            return Data(salt)
        } else {
            return nil
        }
    }
    
    /**
     Derives an encryption key using PBKDF2 with HMAC-SHA256 from a password and a salt.
     
     - Parameters:
        - password: The user's password.
        - salt: A random salt.
     
     - Returns: A derived encryption key as `SymmetricKey` or `nil` if key derivation fails.
     */
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
                    saltSize,
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
                    hashingIterations,
                    &derivedKey,
                    derivedKey.count
                )
            }
        }
        
        if result == kCCSuccess {
//            print("\(SymmetricKey(data: Data(derivedKey)).withUnsafeBytes { Data(Array($0)).base64EncodedString() })") // Useful
            return SymmetricKey(data: Data(derivedKey))
        } else {
            return nil
        }
    }
    
    /**
     Calculates a checksum (SHA-256 hash) for data integrity verification.
     
     - Parameters:
        - Data: The `Data` to calculate the checksum for.
     
     - Returns: The calculated checksum as `Data`.
     */
    func calculateChecksum(data: Data) -> Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        data.withUnsafeBytes { dataBytes in
            _ = CC_SHA256(dataBytes.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return Data(digest)
    }
    
    /**
     Encrypts a `String` with a password.
     
     - Parameters:
        - blob: The `String` to encrypt.
        - password: The users password.
     
     - Returns: The encrypted blob as `Data` or `nil` if encryption fails.
     */
    func encryptBlob(blob: String, password: String) -> Data? {
        guard let salt = generateRandomSalt(),
            let key = deriveKey(password: password, salt: salt),
            let data = blob.data(using: .utf8) else {
          return nil
        }
        
        let combined = salt + data
        let checksum = calculateChecksum(data: combined)
        
        if let sealedBox = try? AES.GCM.seal(data + checksum, using: key) {
            if let combined = sealedBox.combined {
                setSessionKey(key: key)
                return salt + combined
            }
        } else {
            return nil
        }
        
        return nil
    }
    
    /**
     Encrypts a `String` with a session key.
     
     - Parameters:
        - blob: The `String` to encrypt.
        - key: The session key.
        - salt: The random salt associated with the session key.
     
     - Returns: The encrypted blob as `Data` or `nil` if encryption fails.
     */
    func encryptBlob(blob: String, key: SymmetricKey, salt: Data) -> Data? {
        guard let data = blob.data(using: .utf8) else {
          return nil
        }
        
        let combined = salt + data
        let checksum = calculateChecksum(data: combined)
        
        if let sealedBox = try? AES.GCM.seal(data + checksum, using: key) {
            if let combined = sealedBox.combined {
                setSessionKey(key: key)
                return salt + combined
            }
        } else {
            return nil
        }
        
        return nil
    }
    
    /**
     Decrypts encrypted `Data` using a password.
     
     - Parameters:
        - blob: The encrypted blob.
        - password: The user's password.
     
     - Returns: The decrypted blob as `String` or `nil` if decryption fails.
     */
    func decryptBlob(blob: Data, password: String) -> String? {
        let salt = blob.prefix(saltSize)
        
        guard let key = deriveKey(password: password, salt: salt) else {
            return nil
        }
        
        let encryptedData = blob.dropFirst(saltSize)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            let appendedChecksum = decryptedData.suffix(Int(CC_SHA256_DIGEST_LENGTH))
            let expectedChecksum = calculateChecksum(data: salt + decryptedData.dropLast(Int(CC_SHA256_DIGEST_LENGTH)))
            
            if appendedChecksum.base64EncodedData() == expectedChecksum.base64EncodedData() {
                return String(data: decryptedData.dropLast(Int(CC_SHA256_DIGEST_LENGTH)), encoding: .utf8)
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    /**
     Decrypts encrypted `Data` using a session key.
     
     - Parameters:
        - blob: The encrypted blob.
        - key: The session key.
     
     - Returns: The decrypted blob as `String` or `nil` if decryption fails.
     */
    func decryptBlob(blob: Data, key: SymmetricKey) -> String? {
        let salt = blob.prefix(saltSize)
        
        let encryptedData = blob.dropFirst(saltSize)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            let appendedChecksum = decryptedData.suffix(Int(CC_SHA256_DIGEST_LENGTH))
            let expectedChecksum = calculateChecksum(data: salt + decryptedData.dropLast(Int(CC_SHA256_DIGEST_LENGTH)))
            
            if appendedChecksum.base64EncodedData() == expectedChecksum.base64EncodedData() {
                return String(data: decryptedData.dropLast(Int(CC_SHA256_DIGEST_LENGTH)), encoding: .utf8)
            }
        } catch {
            return nil
        }
        
        return nil
    }
    
    /**
     Sets the session key for decryption and clears the previous key from memory.
     
     - Parameters:
        - key: The session key to set.
     */
    func setSessionKey(key: SymmetricKey) {
        clearSessionKey()
        
        key.withUnsafeBytes { keyBytes in
            self.sessionKey = SymmetricKey(data: Data(keyBytes))
        }
    }
    
    /**
     Gets the currently set session key.
     
     - Returns: The current session key as `SymmetricKey` or `nil` if it is not currently set.
     */
    func getSessionKey() -> SymmetricKey? {
        return self.sessionKey
    }
    
    /**
     Clears the currently set session key by zeroing out the key and then setting to `nil`.
     */
    func clearSessionKey() {
        guard var sessionKeyData = self.sessionKey?.withUnsafeBytes({ Data($0) }) else { return }
        
        _ = sessionKeyData.withUnsafeMutableBytes { mutableSessionKeyBytes in
            memset(mutableSessionKeyBytes.baseAddress, 0, mutableSessionKeyBytes.count)
        }
        
        self.sessionKey = nil
    }
    
    /**
     Test function.
     */
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
    /**
     Converts `Data` to a hexadecimal encoded `String`.
     
     - Returns: The hexadecimal encoded representation of the `Data` as `String`.
     */
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

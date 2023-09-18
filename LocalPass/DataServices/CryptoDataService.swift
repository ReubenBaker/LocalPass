//
//  CryptoDataService.swift
//  LocalPass
//
//  Created by Reuben on 06/09/2023.
//

import Foundation
import CryptoKit
import CommonCrypto
import LocalAuthentication

/**
 A utility class for secure encryption and decryption of data using a password-based and key-based approach with data integrity checks.
 
 # Overview:
 
 The `CryptoDataService` class provides methods for securely encrypting and decrypting data, ensuring data integrity through checksums. It uses the following steps:
 
 1. **Salt Generation**: A random salt is generated for each derived key.
 
 2. **Key Derivation**: The random salt, along with the users password is used to derive a unique encryption key using PBKDF2 with HMAC-SHA256.
 
 3. **Encryption**:
    - Data is prepared by converting it into binary form (UTF-8 encoding) and prepending the salt.
    - A checksum of the combined binary data (salt + data) is calculated using SHA-256.
    - AES-GCM encryption is applied to the combined binary data with the checksum appended and without the salt, producing an encrypted data blob.
    - The salt is prepended to the encrypted data blob.
 
 4. **Decryption**:
    - The salt is extracted from the beginning of the data blob.
    - If using a password, the encryption key is derived from the salt + password.
    - If using the session key, the session key is used for the decryption.
    - The encrypted data is then decrypted using the given key.
    - A checksum is calculated based on the extracted salt + decrypted data to verify it matches the checksum from the end of the decrypted data blob.
 
 # Usage:
 
 1. Initialize an instance of `CryptoDataService`.
 
 2. Encrypt sensitive data using the `encryptBlob` method, providing the data and the password.
 
 3. Store the encrypted data.
 
 4. When data access is needed, decrypt it using the `decryptBlob` method with either the given key, or on app startup using the password.
 
 5. After decryption has taken place on app startup, generate a new key and re-encrypt the data to make sure the key is refreshed each session.
 
 This process ensures that data remains confidential and tamper-resistant during storage or transmission. If the password is incorrect or if the data has been tampered with, the decryption will fail, providing an additional layer of security.
 
 # Example:
 ```swift
 let blob = "Data to be encrypted"
 let password = "Password123"
 let service = CryptoDataService()
 
 if let encryptedBlob = service.encryptBlob(blob: blob, password: password) {
    // Store or transmit the encryptedBlob
 
    // To decrypt:
    if let tag = Bundle.main.bundleIdentifier {
        if let key = service.readKeyFromSecureEnclave(tag: tag) {
            if let decryptedBlob = service.decryptBlob(blob: encryptedBlob, key: key) {
                // Handle the decrypted data
            }
        }
    }
 }
 ```
 
 # Key Handling:
 
 The class has been extended to support key storage and retreival. It includes the following functions:
 
 - `writeKeyToSecureEnclave(key:tag:)`: Writes a `SymmetricKey` to the secure enclave with a specified tag.
 - `readKeyFromSecureEnclave(tag:)`: Reads a `SymmetricKey` from the secure enclave using a specified tag.
 - `deleteKeyFromSecureEnclave(tag:)`: Deletes a `SymmetricKey` from the secure enclave using a specified tag.
 
 # Biometrics:
 
 The class has been further extended to support biometric authentication. It includes the following function:
 
 - `authenticateWithBiometrics(completion:)`: Prompts the user for biometric verification, and calls a completion handler with the result (`true` if successful, `false` otherwise).
 
 - Version: 1.0
 - Date: September 17, 2023
 */
class CryptoDataService {
    /**
     Generates a random salt for key derivation.
     
     - Returns: A random salt as `Data` or `nil` if the salt generation fails.
     */
    static func generateRandomSalt() -> Data? {
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
    static func deriveKey(password: String, salt: Data, saltSize: Int = 16, hashingIterations: UInt32 = 10000) -> SymmetricKey? {
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
            return SymmetricKey(data: Data(derivedKey))
        }
        
        return nil
    }
    
    /**
     Calculates a checksum (SHA-256 hash) for data integrity verification.
     
     - Parameters:
        - Data: The `Data` to calculate the checksum for.
     
     - Returns: The calculated checksum as `Data`.
     */
    static func calculateChecksum(data: Data) -> Data {
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
    static func encryptBlob(blob: String, password: String) -> Data? {
        guard let salt = generateRandomSalt(),
              let key = deriveKey(password: password, salt: salt),
              let data = blob.data(using: .utf8) else {
          return nil
        }
        
        let combined = salt + data
        let checksum = calculateChecksum(data: combined)
        
        if let sealedBox = try? AES.GCM.seal(data + checksum, using: key) {
            if let combined = sealedBox.combined {
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
    static func encryptBlob(blob: String, key: SymmetricKey, salt: Data) -> Data? {
        guard let data = blob.data(using: .utf8) else {
          return nil
        }
        
        let combined = salt + data
        let checksum = calculateChecksum(data: combined)
        
        if let sealedBox = try? AES.GCM.seal(data + checksum, using: key) {
            if let combined = sealedBox.combined {
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
    static func decryptBlob(blob: Data, password: String, saltSize: Int = 16) -> String? {
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
    static func decryptBlob(blob: Data, key: SymmetricKey, saltSize: Int = 16) -> String? {
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
}

// Key Handling
extension CryptoDataService {
    /**
     Writes a `SymmetricKey` to the secure enclave with a specified tag.
     
     - Parameters:
        - key: The `SymmetricKey` to be stored securely.
        - tag: A unique identifier for the stored key in the secure enclave.
     
     - Returns: `true` if the key is successfully written to the secure enclave, `false` otherwise.
     */
    static func writeKeyToSecureEnclave(key: SymmetricKey, tag: String) -> Bool {
        let keyData = key.withUnsafeBytes { Data(Array($0)) }
        
        print("Key Set: \(String(describing: key.withUnsafeBytes{ Data($0) }.base64EncodedString()))")
        return writeDataToSecureEnclave(data: keyData, tag: tag)
    }
    
    /**
     Reads a `SymmetricKey` from the secure enclave using a specified tag.
     
     - Parameters:
        - tag: A unique identifier for the key stored in the secure enclave.
     
     - Returns: The stored `SymmetricKey` if it exists, `nil` otherwise.
     */
    static func readKeyFromSecureEnclave(tag: String) -> SymmetricKey? {
        if let keyData = readDataFromSecureEnclave(tag: tag) {
            print("Key Get: \(String(describing: keyData.withUnsafeBytes{ Data($0) }.base64EncodedString()))")
            return SymmetricKey(data: keyData)
        } else {
            return nil
        }
    }
    
    /**
     Deletes a `SymmetricKey` from the secure enclave using a specified tag.
     
     - Parameters:
        - tag: A unique identifier for the key stored in the secure enclave.
     
     - Returns: `true` if the key is successfully deleted from the secure enclave or if it doesn't exist, `false` otherwise.
     */
    static func deleteKeyFromSecureEnclave(tag: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassSymmetric,
            kSecAttrApplicationTag as String: tag
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        print("Key Delete")
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /**
     Writes data to the secure enclave with a specified tag.
     
     - Parameters:
        - data: The `Data` to be stored securely.
        - tag: A unique identifier for the stored `Data` in the secure enclave.
     
     - Returns: `true` if the `Data` is successfully written to the secure enclave, `false` otherwise.
     */
    static func writeDataToSecureEnclave(data: Data, tag: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassSymmetric,
            kSecAttrApplicationTag as String: tag,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        return status == errSecSuccess
    }
    
    /**
     Reads `Data` from the secure enclave using a specified tag.
     
     - Parameters:
        - tag: A unique identifier for the `Data` stored in the secure enclave.
     
     - Returns: The stored `Data` if it exists, `nil` otherwise.
     */
    static func readDataFromSecureEnclave(tag: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassSymmetric,
            kSecAttrApplicationTag as String: tag,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            return data
        } else {
            return nil
        }
    }
}

// Biometrics
extension CryptoDataService {
    /**
     Function to authenticate with biometrics.
     
     This function checks if the device supports biometric authentication, such as TouchID or FaceID, and prompts the user for biometric verification.
     
     - Parameters:
        - completion: A closure that receives the result of the biometric authentication. It is called with `true` if the authentication is successful, `false` otherwise.
     */
    static func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "For signing into LocalPass."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        print("Authentication failed: \(String(describing: error))")
                    }
                }
            }
        }
        
        return completion(false)
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

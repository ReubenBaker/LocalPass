//
//  BiometricHashingDataService.swift
//  LocalPass
//
//  Created by Reuben on 06/09/2023.
//

import Foundation
import LocalAuthentication
import CryptoKit

/*
 TESTING! - Not ready for release yet
 Current implementation (password):
 - When user authenticates, generate a derived key from the password using a random salt + PBKDF2 hashing algorithm
 - Generate derived key from password and salt appended to file from last session
 - Throw away password
 - Store new session key in memory and use it when making changes to that file in a given session, discard on app exit
 Plan (biometrics + password):
 - When user authenticates with biometrics, generate a key using a random key + random salt and store in secure enclave
 - When user authenticates with password, also store the dervied key in the secure enclave
 - Now when the user authenticates with either method, both keys are retrived from the secure enclave and stored in memory for file changes that session
 - When authenticating with a password, both keys can be refreshed for that, however when authenticating with biometrics, only the biometric key can be refreshed as no password has been provided that session
 - Could implement forced reentry of password after a given number of biometric authentications, device restart, or time based etc, to ensure key is regulary changed for the password data, but the password hash would still not be refreshed every session
 */
class BiometricHashingDataService {
    // Attempt Face ID authentication to generate the key and perform encryption/decryption
    func authenticateAndRun() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Attempt Face ID authentication
            let reason = "Unlock to access your data"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                if success {
                    // Biometric authentication succeeded, generate the key and perform encryption/decryption
                    if let biometricKey = self.deriveKey() {
                        self.runTestFunction(biometricKey: biometricKey)
                    }
                } else {
                    // Biometric authentication failed
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Face ID not available or not enabled
        }
    }

    // Generate a key from biometric data
    func deriveKey() -> SymmetricKey? {
        // Replace this with your actual key generation logic from biometric data
        // This can involve a secure key derivation process
        // For demonstration purposes, we'll generate a random key here
        let keySize = 32 // Adjust the size as needed
        var key = [UInt8](repeating: 0, count: keySize)
        _ = SecRandomCopyBytes(kSecRandomDefault, keySize, &key)
        let keyData = key.withUnsafeBytes { Data($0) } // remove
        print("Key: \(keyData.hexEncodedString())")
        return SymmetricKey(data: Data(key))
    }

    // Perform encryption and decryption using the biometric-derived key
    func runTestFunction(biometricKey: SymmetricKey) {
        // Example usage
        let plaintextString = "Sensitive data to be encrypted"
        
        do {
            let encryptedData = try encryptBlob(plaintextString, biometricKey: biometricKey)
            
            print("Encrypted String: \(encryptedData)")
            print("Encrypted String: \(encryptedData.base64EncodedString())")
            
            let decryptedString = try decryptBlob(encryptedData, biometricKey: biometricKey)
            
            print("Decrypted String: \(decryptedString)")
        } catch {
            print("Error: \(error)")
        }
    }
    
    // Encrypt a string with a random salt for biometric-based encryption
    func encryptBlob(_ string: String, biometricKey: SymmetricKey) throws -> Data {
        let salt = generateRandomSalt() // Generate a random salt
        let data = string.data(using: .utf8)!
        let sealedBox = try AES.GCM.seal(data, using: biometricKey)
        let ciphertextWithSalt = salt + sealedBox.combined!
        return ciphertextWithSalt
    }

    // Decrypt data with a random salt for biometric-based encryption
    func decryptBlob(_ data: Data, biometricKey: SymmetricKey) throws -> String {
        let saltSize = 16 // Adjust the size as needed
//        let salt = data.prefix(saltSize)
        let encryptedData = data.dropFirst(saltSize)
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: biometricKey)
        return String(data: decryptedData, encoding: .utf8) ?? "Failed to decrypt"
    }
    

    
    // Generate a random salt
    func generateRandomSalt() -> Data {
        var salt = [UInt8](repeating: 0, count: 16) // Adjust the size as needed
        _ = SecRandomCopyBytes(kSecRandomDefault, salt.count, &salt)
        return Data(salt)
    }
}


/*
 func storeKeyInSecureEnclave(key: Data, keyIdentifier: String) -> Bool {
     let context = LAContext()
     var error: NSError?
     
     if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
         // Attempt authentication with the Secure Enclave
         let reason = "Authenticate to store key in Secure Enclave"
         context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { (success, error) in
             if success {
                 // Biometric authentication succeeded, store the key in the Secure Enclave
                 let query: [String: Any] = [
                     kSecClass as String: kSecClassKey,
                     kSecAttrApplicationTag as String: keyIdentifier,
                     kSecValueData as String: key,
                     kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                     kSecUseAuthenticationContext as String: context
                 ]
                 
                 let status = SecItemAdd(query as CFDictionary, nil)
                 
                 if status == errSecSuccess {
                     print("Key stored in Secure Enclave successfully.")
                 } else {
                     print("Failed to store key in Secure Enclave with status: \(status)")
                 }
             } else {
                 // Biometric authentication failed
                 print("Biometric authentication failed.")
             }
         }
     } else {
         // Biometric authentication not available or not enabled
         print("Biometric authentication not available or not enabled.")
     }
     
     return false
 }

 import Foundation
 import LocalAuthentication
 import Security

 class KeychainHelper {
     // Retrieve a cryptographic key from the Keychain after successful biometric authentication
     func getKeyAfterBiometricAuth(completion: @escaping (Data?) -> Void) {
         let context = LAContext()
         var error: NSError?
         
         if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
             // Attempt biometric authentication
             let reason = "Unlock to access your key"
             context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { (success, error) in
                 if success {
                     // Biometric authentication succeeded, retrieve the key from the Keychain
                     if let keyData = self.getKeyFromKeychain() {
                         completion(keyData)
                     } else {
                         completion(nil) // Failed to retrieve key
                     }
                 } else {
                     // Biometric authentication failed
                     completion(nil)
                 }
             }
         } else {
             // Biometric authentication not available or not enabled
             completion(nil)
         }
     }
     
     // Retrieve a cryptographic key from the Keychain
     private func getKeyFromKeychain() -> Data? {
         let query: [String: Any] = [
             kSecClass as String: kSecClassKey,
             kSecReturnData as String: true,
             kSecMatchLimit as String: kSecMatchLimitOne
         ]
         
         var result: AnyObject?
         let status = SecItemCopyMatching(query as CFDictionary, &result)
         
         if status == errSecSuccess, let keyData = result as? Data {
             return keyData
         }
         
         return nil
     }
 }

 */

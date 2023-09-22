//
//  AccountsDataService.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import Foundation
import SwiftUI

class AccountsDataService {
    static private let localPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localpassaccounts.txt")
    static private let initializationGroup = DispatchGroup()
    
    static func getBlob() -> Data? {
        var blob = try? Data(contentsOf: localPath)
        
        if LocalPassApp.settings.iCloudSync {
            getiCloudPath { iCloudPath in
                if let path = iCloudPath {
                    let iCloudBlob = try? Data(contentsOf: path)
                    
                    blob = iCloudBlob ?? blob
                }
            }
            
            initializationGroup.wait()
        }
        
        return blob
    }
    
    static func formatForSave(_ accounts: [Account]?) -> String {
        if accounts != nil {
            var formattedString: String = ""
            
            for account in accounts! {
                formattedString += "\(account.name);"
                formattedString += "\(account.username);"
                formattedString += "\(account.password);"
                formattedString += "\(account.url != nil ? account.url! : String(describing: account.url));"
                formattedString += "\(String(describing: account.creationDateTime));"
                formattedString += "\(account.updatedDateTime != nil ? String(describing: account.updatedDateTime!) : String(describing: account.updatedDateTime));"
                formattedString += "\(account.starred);"
                formattedString += "\(account.otpSecret != nil ? account.otpSecret! : String(describing: account.otpSecret));"
                formattedString += "\(account.id);"
                formattedString += "~"
            }
            
            return formattedString
        }
        
        return "empty"
    }
    
    static func parseData(_ blob: Data?) -> [Account]? {
        if let blob = blob {
            if let tag = Bundle.main.bundleIdentifier {
                if let key = CryptoDataService.readKey(tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync) {
                    if let decryptedBlob = CryptoDataService.decryptBlob(blob: blob, key: key) {
                        if decryptedBlob == "empty" {
                            return nil
                        }
                        
                        let blobEntries = decryptedBlob.split(separator: "~")
                        var accounts: [Account]? = nil
                        
                        for blobEntry in blobEntries {
                            let blobEntryData = blobEntry.split(separator: ";")
                            accounts = (accounts ?? []) + [
                                Account(
                                    name: String(blobEntryData[0]),
                                    username: String(blobEntryData[1]),
                                    password: String(blobEntryData[2]),
                                    url: blobEntryData[3] != "nil" ? String(blobEntryData[3]) : nil,
                                    creationDateTime: GlobalHelperDataService.dateFormatter.date(from: String(blobEntryData[4])) ?? Date(),
                                    updatedDateTime: blobEntryData[5] != "nil" ? GlobalHelperDataService.dateFormatter.date(from: String(blobEntryData[5])) ?? Date() : nil,
                                    starred: blobEntryData[6] == "true" ? true : false,
                                    otpSecret: blobEntryData[7] != "nil" ? String(blobEntryData[7]) : nil,
                                    id: UUID(uuidString: String(blobEntryData[8])) ?? UUID()
                                )
                            ]
                        }
                        
                        return accounts
                    }
                }
            }
        }
        
        return nil   
    }
    
    static func getAccountData() -> [Account]? {
        if AuthenticationViewModel.shared.authenticated {
            let blob = getBlob()
            return parseData(blob)
        }
        
        return nil
    }
    
    static func saveData(_ accounts: [Account]?, salt: Data? = nil) throws {
        do {
            let blob = formatForSave(accounts)
            
            if let tag = Bundle.main.bundleIdentifier {
                if let key = CryptoDataService.readKey(tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync) {
                    if let originalData = getBlob() {
                        let salt = salt ?? originalData.prefix(16)
                        
                        if let encryptedBlob = CryptoDataService.encryptBlob(blob: blob, key: key, salt: salt) {
                            try encryptedBlob.write(to: localPath, options: .atomic)
                            
                            if LocalPassApp.settings.iCloudSync {
                                getiCloudPath { iCloudPath in
                                    if let path = iCloudPath {
                                        do {
                                            try encryptedBlob.write(to: path, options: .atomic)
                                        } catch {
                                            print("Error syncing iCloud data: \(error)")
                                        }
                                    }
                                }
                                
                                initializationGroup.wait()
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error writing accounts data: \(error)")
        }
    }
    
    static func getiCloudPath(completion: @escaping (URL?) -> Void) {
        initializationGroup.enter()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let iCloudUrl = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.reuben.LocalPass") {
                completion(iCloudUrl.appendingPathComponent("Documents").appendingPathComponent("localpassaccounts.txt"))
            }
            
            initializationGroup.leave()
        }
        
        completion(nil)
    }
    
    static func removeiCloudData() {
        getiCloudPath { iCloudPath in
            if let path = iCloudPath {
                do {
                    try FileManager.default.removeItem(at: path)
                } catch {
                    print("Error removing iCloud file: \(error)")
                }
            }
        }
        
        initializationGroup.wait()
    }
}

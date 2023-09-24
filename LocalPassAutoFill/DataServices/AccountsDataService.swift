//
//  AccountsDataService.swift
//  LocalPassAutoFill
//
//  Created by Reuben on 24/09/2023.
//

import Foundation

class AccountsDataService {
    static private let localPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.reuben.LocalPass")?.appendingPathComponent("localpassaccounts.txt")
    static private let initializationGroup = DispatchGroup()
    
    static func getBlob() -> Data? {
        var blob: Data?
        
        if let path = localPath {
            blob = try? Data(contentsOf: path)
        }
        
        if let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass") {
            if sharedUserDefaults.bool(forKey: "iCloudSync") {
                getiCloudPath { iCloudPath in
                    if let path = iCloudPath {
                        let iCloudBlob = try? Data(contentsOf: path)
                        
                        blob = iCloudBlob ?? blob
                    }
                }
                
                initializationGroup.wait()
            }
        }
        
        return blob
    }
    
    static func parseData(_ blob: Data?) -> [Account]? {
        if let blob = blob,
           let tag = Bundle.main.bundleIdentifier?.components(separatedBy: ".").dropLast().joined(separator: "."),
           let sharedUserDefaults = UserDefaults(suiteName: "group.com.reuben.LocalPass"),
           let key = CryptoDataService.readKey(tag: tag, iCloudSync: sharedUserDefaults.bool(forKey: "iCloudSync")),
           let decryptedBlob = CryptoDataService.decryptBlob(blob: blob, key: key) {
            
            if decryptedBlob == "empty" {
                return nil
            }
            
            let blobEntries = decryptedBlob.split(separator: "~~~")
            var accounts: [Account]? = nil
            
            for blobEntry in blobEntries {
                let blobEntryData = blobEntry.split(separator: ";;;")
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
        
        return nil
    }
    
    static func getAccountData() -> [Account]? {
        if AuthenticationViewModel.shared.authenticated {
            let blob = getBlob()
            return parseData(blob)
        }
        
        return nil
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
}

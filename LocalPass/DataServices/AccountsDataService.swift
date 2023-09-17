//
//  AccountsDataService.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import Foundation
import SwiftUI

class AccountsDataService {
    private let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localpassaccounts.txt")
    private var iCloudPath: URL? = nil
    private let initializationGroup = DispatchGroup()
    private let cryptoDataService = CryptoDataService()
    private var settings = Settings()
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        return dateFormatter
    }
    
    init() {
        initializationGroup.enter()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let iCloudUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                self.iCloudPath = iCloudUrl.appendingPathComponent("Documents").appendingPathComponent("localpassaccounts.txt")
            }
            
            self.initializationGroup.leave()
        }
    }
    
    func getBlob() -> Data? {
        do {
            let blob = try Data(contentsOf: path)
            var iCloudBlob: Data? = nil
            
            initializationGroup.wait()
            
            if let path = iCloudPath {
                if settings.iCloudSync {
                    do {
                        iCloudBlob = try Data(contentsOf: path)
                    } catch {
                        print("Couldn't retreive iCloud blob: \(error)")
                    }
                    
                    if iCloudBlob != nil {
                        return iCloudBlob
                    }
                }
            }
            
            return blob
        } catch {
            return nil
        }
    }
    
    func formatForSave(accounts: [Account]?) -> String {
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
    
    func parseData(blob: Data?) -> [Account]? {
        if let blob = blob {
            if let tag = Bundle.main.bundleIdentifier {
                if let key = cryptoDataService.readKeyFromSecureEnclave(tag: tag) {
                    if let decryptedBlob = cryptoDataService.decryptBlob(blob: blob, key: key) {
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
                                    creationDateTime: dateFormatter.date(from: String(blobEntryData[4])) ?? Date(),
                                    updatedDateTime: blobEntryData[5] != "nil" ? dateFormatter.date(from: String(blobEntryData[5])) ?? Date() : nil,
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
    
    func getAccountData() -> [Account]? {
        let blob = getBlob()
        return parseData(blob: blob)
    }
    
    func saveData(accounts: [Account]?) throws {
        do {
            let blob = formatForSave(accounts: accounts)
            
            if let tag = Bundle.main.bundleIdentifier {
                if let key = cryptoDataService.readKeyFromSecureEnclave(tag: tag) {
                    if let originalData = getBlob() {
                        let salt = originalData.prefix(16)
                        
                        if let encryptedBlob = cryptoDataService.encryptBlob(blob: blob, key: key, salt: salt) {
                            try encryptedBlob.write(to: path, options: .atomic)
                            
                            initializationGroup.wait()
                            
                            if settings.iCloudSync {
                                if let path = iCloudPath {
                                    try encryptedBlob.write(to: path, options: .atomic)
                                }
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error writing accounts data: \(error)")
        }
            
    }
    
    func removeiCloudData() {
        initializationGroup.wait()
        
        if let iCloudPath = self.iCloudPath {
            do {
                try FileManager.default.removeItem(at: iCloudPath)
            } catch {
                print("Error removing iCloud file: \(error)")
            }
        }
    }
}

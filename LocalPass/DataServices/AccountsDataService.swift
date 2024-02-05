//
//  AccountsDataService.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import Foundation

class AccountsDataService {
    static private let localPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.reuben.LocalPass")?.appendingPathComponent("localpassaccounts.txt")
    
    static func getBlob() -> Data? {
        var blob: Data?
        
        if let path = localPath {
            blob = try? Data(contentsOf: path)
        }
        
        return blob
    }
    
    static func formatForSave(_ accounts: [Account]?) -> String {
        if let accounts = accounts {
            var formattedString: String = ""
            
            for account in accounts {
                formattedString += "\(account.name != "" ? String(describing: account.name) : "?");;;"
                formattedString += "\(account.username != "" ? String(describing: account.username) : "?");;;"
                formattedString += "\(account.password != "" ? String(describing: account.password) : "?");;;"
                formattedString += "\(account.url ?? (account.url != "" ? String(describing: account.url) : "?"));;;"
                formattedString += "\(GlobalHelperDataService.dateFormatter.string(from: account.creationDateTime));;;"
                formattedString += "\(account.updatedDateTime != nil ? GlobalHelperDataService.dateFormatter.string(from: account.updatedDateTime ?? Date(timeIntervalSince1970: 0)) : String(describing: account.updatedDateTime));;;"
                formattedString += "\(String(describing: account.starred));;;"
                formattedString += "\(account.otpSecret ?? (account.otpSecret != "" ? String(describing: account.otpSecret) : "?"));;;"
                formattedString += "\(String(describing: account.id));;;"
                formattedString += "~~~"
            }
            
            return formattedString
        }
        
        return "empty"
    }
    
    static func parseData(_ blob: Data?) -> [Account]? {
        if let blob = blob,
           let tag = Bundle.main.bundleIdentifier,
           let key = CryptoDataService.readKey(tag: tag),
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
                        creationDateTime: GlobalHelperDataService.dateFormatter.date(from: String(blobEntryData[4])) ?? Date(timeIntervalSince1970: 0),
                        updatedDateTime: blobEntryData[5] != "nil" ? GlobalHelperDataService.dateFormatter.date(from: String(blobEntryData[5])) ?? Date(timeIntervalSince1970: 0) : nil,
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
    
    static func saveData(_ accounts: [Account]?, salt: Data? = nil) {
        do {
            let blob = formatForSave(accounts)
            
            if let tag = Bundle.main.bundleIdentifier,
               let key = CryptoDataService.readKey(tag: tag),
               let originalData = getBlob() {
                
                let salt = salt ?? originalData.prefix(16)
                
                if let encryptedBlob = CryptoDataService.encryptBlob(blob: blob, key: key, salt: salt),
                   let path = localPath {
                    
                    try encryptedBlob.write(to: path, options: .atomic)
                }
            }
        } catch {
            print("Error writing accounts data: \(error)")
        }
    }
}

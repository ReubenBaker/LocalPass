//
//  AccountsDataService.swift
//  LocalPass
//
//  Created by Reuben on 29/08/2023.
//

import Foundation
import SwiftUI

class AccountsDataService {
    let fileManager = FileManager()
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(Bundle.main.bundleIdentifier!)
    
    init() {
        print(getBlob())
        if getBlob() == nil || getBlob() == "" {
            do {
                if let testData = formatForSave(accounts: AccountTestDataService.accounts) {
                    try testData.write(to: path, atomically: true, encoding: .utf8)
                }
            } catch {
                print("Error writing data: \(error)")
            }
        }
    }
    
    func getBlob() -> String? {
        do {
            let blob = try String(contentsOf: path)
            return blob
        } catch {
            return nil
        }
    }
    
    func formatForSave(accounts: [Account]?) -> String? {
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
                formattedString += "~"
            }
            
            return formattedString
        }
        
        return nil
    }
    
    func parseData(blob: String?) -> [Account]? {
        if blob != nil {
            let blobEntries = blob!.split(separator: "~")
            var accounts: [Account]? = nil
            
            for blobEntry in blobEntries {
                let blobEntryData = blobEntry.split(separator: ";")
                accounts = (accounts ?? []) + [
                    Account(
                        name: String(blobEntryData[0]),
                        username: String(blobEntryData[1]),
                        password: String(blobEntryData[2]),
                        url: blobEntryData[3] != "nil" ? String(blobEntryData[3]) : nil,
                        creationDateTime: DateFormatter().date(from: String(blobEntryData[4])) ?? Date(),
                        updatedDateTime: blobEntryData[5] != "nil" ? DateFormatter().date(from: String(blobEntryData[5])) ?? Date() : nil,
                        starred: blobEntryData[6] == "true" ? true : false
                    )
                ]
            }
            
            return accounts
        }
        
        return nil
    }
    
    func getAccountData() -> [Account]? {
        let blob = getBlob()
        return parseData(blob: blob)
    }
    
    func saveData(accounts: [Account]?) {
        do {
            if let blob = formatForSave(accounts: accounts) {
                try blob.write(to: path, atomically: true, encoding: .utf8)
            }
        } catch {
            print("Error writing data: \(error)")
        }
    }
}

//
//  NotesDataService.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import Foundation

class NotesDataService {
    static private let localPath = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.reuben.LocalPass")?.appendingPathComponent("localpassnotes.txt")
    static private let initializationGroup = DispatchGroup()
    
    static func getBlob() -> Data? {
        var blob: Data?
        
        if let path = localPath {
            blob = try? Data(contentsOf: path)
        }
        
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
    
    static func formatForSave(_ notes: [Note]?) -> String {
        if let notes = notes {
            var formattedString: String = ""
            
            for note in notes {
                formattedString += "\(note.title != "" ? String(describing: note.title) : "?");;;"
                formattedString += "\(note.body != "" ? String(describing: note.body) : "?");;;"
                formattedString += "\(GlobalHelperDataService.dateFormatter.string(from: note.creationDateTime));;;"
                formattedString += "\(note.updatedDateTime != nil ? GlobalHelperDataService.dateFormatter.string(from: note.updatedDateTime ?? Date(timeIntervalSince1970: 0)) : String(describing: note.updatedDateTime));;;"
                formattedString += "\(String(describing: note.starred));;;"
                formattedString += "\(String(describing: note.id));;;"
                formattedString += "~~~"
            }
            
            return formattedString
        }
        
        return "empty"
    }
    
    static func parseData(_ blob: Data?) -> [Note]? {
        if let blob = blob,
           let tag = Bundle.main.bundleIdentifier,
           let key = CryptoDataService.readKey(tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync),
           let decryptedBlob = CryptoDataService.decryptBlob(blob: blob, key: key) {
            
            if decryptedBlob == "empty" {
                return nil
            }
            
            let blobEntries = decryptedBlob.split(separator: "~~~")
            var notes: [Note]? = nil
            
            for blobEntry in blobEntries {
                let blobEntryData = blobEntry.split(separator: ";;;")
                notes = (notes ?? []) + [
                    Note(
                        title: String(blobEntryData[0]),
                        body: String(blobEntryData[1]),
                        creationDateTime: GlobalHelperDataService.dateFormatter.date(from: String(blobEntryData[2])) ?? Date(timeIntervalSince1970: 0),
                        updatedDateTime: blobEntryData[3] != "nil" ? GlobalHelperDataService.dateFormatter.date(from: String(blobEntryData[3])) ?? Date(timeIntervalSince1970: 0) : nil,
                        starred: blobEntryData[4] == "true" ? true : false,
                        id: UUID(uuidString: String(blobEntryData[5])) ?? UUID()
                    )
                ]
            }
            
            return notes
        }
        
        return nil
    }
    
    static func getNoteData() -> [Note]? {
        if AuthenticationViewModel.shared.authenticated {
            let blob = getBlob()
            return parseData(blob)
        }
        
        return nil
    }
    
    static func saveData(_ notes: [Note]?, salt: Data? = nil) {
        do {
            let blob = formatForSave(notes)
            
            if let tag = Bundle.main.bundleIdentifier,
               let key = CryptoDataService.readKey(tag: tag, iCloudSync: LocalPassApp.settings.iCloudSync),
               let originalData = getBlob() {
                
                let salt = salt ?? originalData.prefix(16)
                
                if let encryptedBlob = CryptoDataService.encryptBlob(blob: blob, key: key, salt: salt),
                   let path = localPath {
                    
                    try encryptedBlob.write(to: path, options: .atomic)
                    
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
        } catch {
            print("Error writing notes data: \(error)")
        }
    }
    
    static func getiCloudPath(completion: @escaping (URL?) -> Void) {
        initializationGroup.enter()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let iCloudUrl = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.reuben.LocalPass") {
                completion(iCloudUrl.appendingPathComponent("Documents").appendingPathComponent("localpassnotes.txt"))
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


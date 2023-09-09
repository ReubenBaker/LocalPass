//
//  NotesDataService.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import Foundation
import SwiftUI

class NotesDataService {
    private var testPassword: String? = "password" // REMOVE!
    private var settings = Settings()
    private let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localpassnotes.txt")
    private var iCloudPath: URL? = nil
    private let initializationGroup = DispatchGroup()
    private let cryptoDataService = CryptoDataService()
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        return dateFormatter
    }
    private enum SaveError: Error {
        case defaultError
    }
    
    init() {
        initializationGroup.enter()
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let iCloudUrl = FileManager.default.url(forUbiquityContainerIdentifier: nil) {
                self.iCloudPath = iCloudUrl.appendingPathComponent("Documents").appendingPathComponent("localpassnotes.txt")
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
    
    func formatForSave(notes: [Note]?) -> String {
        if notes != nil {
            var formattedString: String = ""
            
            for note in notes! {
                formattedString += "\(note.title);"
                formattedString += "\(note.body);"
                formattedString += "\(String(describing: note.creationDateTime));"
                formattedString += "\(note.updatedDateTime != nil ? String(describing: note.updatedDateTime!) : String(describing: note.updatedDateTime));"
                formattedString += "\(note.starred);"
                formattedString += "\(note.id);"
                formattedString += "~"
            }
            
            return formattedString
        }
        
        return "empty"
    }
    
    func parseData(blob: Data?) -> [Note]? {
        if let blob = blob {
            if let key = cryptoDataService.getSessionKey() {
                if let decryptedBlob = cryptoDataService.decryptBlob(blob: blob, key: key) {
                    if decryptedBlob == "empty" {
                        return nil
                    }
                    
                    let blobEntries = decryptedBlob.split(separator: "~")
                    var notes: [Note]? = nil
                    
                    for blobEntry in blobEntries {
                        let blobEntryData = blobEntry.split(separator: ";")
                        notes = (notes ?? []) + [
                            Note(
                                title: String(blobEntryData[0]),
                                body: String(blobEntryData[1]),
                                creationDateTime: dateFormatter.date(from: String(blobEntryData[2])) ?? Date(),
                                updatedDateTime: blobEntryData[3] != "nil" ? dateFormatter.date(from: String(blobEntryData[3])) ?? Date() : nil,
                                starred: blobEntryData[4] == "true" ? true : false,
                                id: UUID(uuidString: String(blobEntryData[5])) ?? UUID()
                            )
                        ]
                    }
                    
                    return notes
                }
            } else if let password = testPassword {
                if let decryptedBlob = cryptoDataService.decryptBlob(blob: blob, password: password) {
                    if decryptedBlob == "empty" {
                        return nil
                    }
                    
                    let blobEntries = decryptedBlob.split(separator: "~")
                    var notes: [Note]? = nil
                    
                    for blobEntry in blobEntries {
                        let blobEntryData = blobEntry.split(separator: ";")
                        notes = (notes ?? []) + [
                            Note(
                                title: String(blobEntryData[0]),
                                body: String(blobEntryData[1]),
                                creationDateTime: dateFormatter.date(from: String(blobEntryData[2])) ?? Date(),
                                updatedDateTime: blobEntryData[3] != "nil" ? dateFormatter.date(from: String(blobEntryData[3])) ?? Date() : nil,
                                starred: blobEntryData[4] == "true" ? true : false,
                                id: UUID(uuidString: String(blobEntryData[5])) ?? UUID()
                            )
                        ]
                    }

                    return notes
                }
            } else {
                return nil
            }
        }
        
        return nil
    }
    
    func getNoteData() -> [Note]? {
        let blob = getBlob()
        return parseData(blob: blob)
    }
    
    func saveData(notes: [Note]?) throws {
        do {
            let blob = formatForSave(notes: notes)
            
            if let key = cryptoDataService.getSessionKey() {
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
            } else if let password = testPassword {
                if let encryptedBlob = cryptoDataService.encryptBlob(blob: blob, password: password) {
                    try encryptedBlob.write(to: path, options: .atomic)
                    
                    initializationGroup.wait()
                    
                    if settings.iCloudSync {
                        if let path = iCloudPath {
                            try encryptedBlob.write(to: path, options: .atomic)
                        }
                    }
                }
            } else {
                throw SaveError.defaultError
            }
        } catch {
            print("Error writing notes data: \(error)")
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

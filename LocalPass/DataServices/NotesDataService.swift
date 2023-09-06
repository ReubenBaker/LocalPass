//
//  NotesDataService.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import Foundation
import SwiftUI

class NotesDataService {
    @StateObject private var settings = Settings()
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localpassnotes.txt")
    var iCloudPath: URL? = nil
    let initializationGroup = DispatchGroup()
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ"
        return dateFormatter
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
    
    func getBlob() -> String? {
        do {
            let blob = try String(contentsOf: path)
            var iCloudBlob: String? = nil
            
            initializationGroup.wait()
            
            if settings.iCloudSync && iCloudPath != nil {
                iCloudBlob = try String(contentsOf: path)
                
                if iCloudBlob != nil {
                    return iCloudBlob
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
    
    func parseData(blob: String?) -> [Note]? {
        if blob != nil {
            if blob == "empty" {
                return nil
            }
            
            let blobEntries = blob?.split(separator: "~")
            var notes: [Note]? = nil
            
            for blobEntry in blobEntries ?? [] {
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
        
        return nil
    }
    
    func getNoteData() -> [Note]? {
        let blob = getBlob()
        return parseData(blob: blob)
    }
    
    func saveData(notes: [Note]?) {
        do {
            let blob = formatForSave(notes: notes)
            try blob.write(to: path, atomically: true, encoding: .utf8)
            
            initializationGroup.wait()
            
            if settings.iCloudSync && iCloudPath != nil {
                try blob.write(to: iCloudPath!, atomically: true, encoding: .utf8)
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

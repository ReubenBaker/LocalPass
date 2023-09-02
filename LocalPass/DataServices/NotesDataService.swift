//
//  NotesDataService.swift
//  LocalPass
//
//  Created by Reuben on 01/09/2023.
//

import Foundation

class NotesDataService {
    let fileManager = FileManager()
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("localpassnotes.txt")
    
    init() {
        if !fileManager.fileExists(atPath: path.description) {
            do {
                try "empty".write(to: path, atomically: true, encoding: .utf8)
            } catch {
                print("Error initialising file: \(error)")
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
    
    func formatForSave(notes: [Note]?) -> String {
        if notes != nil {
            var formattedString: String = ""
            
            for note in notes! {
                formattedString += "\(note.title)"
                formattedString += "\(note.body)"
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
                        body: String(blobEntryData[1])
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
        } catch {
            print("Error writing notes data: \(error)")
        }
    }
}

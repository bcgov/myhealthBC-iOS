//
//  MigrationService.swift
//  BCVaccineCard
//
//  Created by Amir Shayegh on 2022-11-22.
//

import Foundation

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}

class MigrationService {
    
    /// if the app has been upldates since the last launch, deletes the sqlite databse file.
    func removeExistingDBIfNeeded() {
        if !UpdateServiceStorage.appWasUpdated {return}
        let files = findSqliteFiles()
        for file in files where FileManager.default.fileExists(atPath: file.path) {
            do {
                try FileManager.default.removeItem(atPath: file.path)
            } catch {
                print("Could not delete file")
            }
        }
    }
    
    /// finds all sqlite files for this app
    /// - Returns: array of paths to sqlite files
    private func findSqliteFiles() -> [URL] {
        guard let directoryUrls = FileManager.default.urls(for: .documentDirectory) else {
            return []
        }
        return directoryUrls.filter({$0.absoluteString.contains(".sqlite") })
    }
}

//
//  FileManager.swift
//  FileManager
//
//  Copyright © 2018 E-legion. All rights reserved.
//

import Foundation

public struct FileManagerService {
    
    public typealias FileItem = (name: String, isDirectory: Bool)
    
    // MARK: Public
    func listFiles(in dir: URL?) -> [FileItem] {
        guard let directoryPath = dir?.path,
            let directory = try? FileManager.default.contentsOfDirectory(atPath: directoryPath) else {
                return []
        }
        var filesList: [FileItem] = []
        for file in directory {
            if let fileURL = dir?.appendingPathComponent(file) {
                filesList.append((name: file, isDirectory: fileURL.isDirectory))
            }
        }
        filesList = filesList.sorted(by: { $0.name < $1.name })
        filesList = filesList.sorted(by: { $0.isDirectory && !$1.isDirectory })
        return filesList
    }

    func writeFile(containing: String, directory url: URL, withName name: String) {
        let filePath = url.path + "/" + name
        let rawData: Data? = containing.data(using: .utf8)
        FileManager.default.createFile(atPath: filePath, contents: rawData, attributes: nil)
    }
    
    func createFolder(to path: URL, withName name: String) {
        do {
            let docURL = path.appendingPathComponent(name)
            try FileManager.default.createDirectory(at: docURL, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func deleteFile(at url: URL, withName name: String) {
        let filePath = url.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: filePath)
    }
    
    // MARK: Private
    func getURL(for directory: AppDirectories) -> URL? {
        
        switch directory {
        case .Documents:
            guard let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
            }
            return documents
            
        case .Inbox:
            guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(AppDirectories.Inbox.rawValue) else {
                return nil
            }
            
            if FileManager.default.fileExists(atPath: "\(url)") {
            } else {
                try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            }
            
            return url
            
        case .Library:
            guard let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
                return nil
            }
            return library
            
        case .Tmp:
            return FileManager.default.temporaryDirectory
        }
    }
    
}

extension URL {
    var isDirectory: Bool {
        let values = try? resourceValues(forKeys: [.isDirectoryKey])
        return values?.isDirectory ?? false
    }
}


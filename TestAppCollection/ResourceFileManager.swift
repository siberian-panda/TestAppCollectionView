//
//  ResourceFileManager.swift
//  TestAppCollection
//
//  Created by Artem Farafonov on 17.10.2021.
//

import UIKit

class ResourceFileManager: NSObject {

    public func save(data: Data, with fileName: String) -> String? {
        guard let filePath = _pathToResourceFile(with: fileName) else {
            print("Failed to save file with name \(fileName). Error: Invalid destination path")
            return nil
        }
        do {
            try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
        } catch let error as NSError {
            print("Failed to save file with name \(fileName). Error: \(error.localizedDescription)")
            return nil
        }
        return filePath
    }
    
    public func readResourceFile(with fileName: String) -> Data? {
        guard let filePath = _pathToResourceFile(with: fileName) else {
            print("Failed to load file with name \(fileName). Error: Invalid destination path")
            return nil
        }
        if !FileManager.default.fileExists(atPath: filePath) {
            print("Failed to load file with name \(fileName). Error: File does not exist")
            return nil
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            return data
        } catch let error as NSError {
            print("Failed to load file with name \(fileName). Error: \(error.localizedDescription)")
        }
        return nil
    }

    public func removeResourceFile(with fileName: String) {
        guard let filePath = _pathToResourceFile(with: fileName) else {
            print("Failed to remove file with name \(fileName). Error: Invalid destination path")
            return
        }
        do {
            try FileManager.default.removeItem(atPath: filePath)
        } catch let error as NSError {
            print("Failed to remove file at path \(filePath). Error: \(error.localizedDescription)")
        }
    }
    
    private func _pathToResourceFile(with fileName: String) -> String? {
        guard let resourcesDirectoryPath = _resourcesDirectoryPath() else {
            return nil
        }
        return (resourcesDirectoryPath as NSString).appendingPathComponent(fileName)
    }
    
    private func _resourcesDirectoryPath() -> String? {
        _directoryCachePath(directoryName: FileManagerConstants.resourcesDirectoryName)
    }

    private func _directoryCachePath(directoryName: String) -> String? {
        guard let cachesDirectoryPath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            return nil
        }
        let pathForDirectoryName = (cachesDirectoryPath as NSString).appendingPathComponent(directoryName)
        if !FileManager.default.fileExists(atPath: pathForDirectoryName) {
            do {
                try FileManager.default.createDirectory(atPath: pathForDirectoryName, withIntermediateDirectories: false, attributes: nil)
            } catch _ as NSError {
                return nil
            }
        }
        return pathForDirectoryName
    }
    
}

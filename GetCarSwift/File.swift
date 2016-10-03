//
//  File.swift
//  GetCarSwift
//
//  Created by 周斌佳 on 15/11/2.
//  Copyright © 2015年 周斌佳. All rights reserved.
//

import Foundation

struct FileError {
    static let NotDirectoryError = NSError(domain: "file should be directory", code: 101, userInfo: nil)
}

struct File {

    var path: String

    init(path: String) {
        if path.hasPrefix("/") {
            self.path = path
        } else {
            self.path = File.docFile.path + path
        }
        fixPathIfNeeded()
    }

    init(dir: File, name: String) throws {
        if !dir.isDirectory() {
            throw FileError.NotDirectoryError
        }
        self.init(path: dir.path + name)
    }

    mutating func fixPathIfNeeded() {
        if isDirectory() && !self.path.hasSuffix("/") {
            self.path += "/"
        }
    }

    func isDirectory() -> Bool {
        var isDir = ObjCBool(false)
        FileManager.default.fileExists(atPath: self.path, isDirectory: &isDir)
        return isDir.boolValue
    }

    mutating func mkdir() {
        if isDirectory() {
            return
        }
        _ = try? FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: false, attributes: nil)
        fixPathIfNeeded()
    }

    mutating func mkdirs() {
        if isDirectory() {
            return
        }
        _ = try? FileManager.default.createDirectory(atPath: self.path, withIntermediateDirectories: true, attributes: nil)
        fixPathIfNeeded()
    }

    func getName() -> String {
        return self.path.characters.split(separator: Character("/")).map { String($0) }.last!
    }

    func list() throws -> [String] {
        return try FileManager.default.contentsOfDirectory(atPath: self.path)
    }

    func move(toFile: File) -> Bool {
        do {
            try FileManager.default.moveItem(atPath: self.path, toPath: toFile.path)
        } catch {
            return false
        }
        return true
    }

    func delete() -> Bool {
        do {
            try FileManager.default.removeItem(atPath: self.path)
        } catch {
            return false
        }
        return true
    }

    func listFiles() throws -> [File] {
        let files = try FileManager.default.contentsOfDirectory(atPath: self.path)
        return files.flatMap { try? File(dir: self, name: $0 ) }
    }

    static let docFile = File(path: (try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true))?.path ?? "")
}

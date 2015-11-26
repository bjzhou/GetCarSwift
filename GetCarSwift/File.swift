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
        NSFileManager.defaultManager().fileExistsAtPath(self.path, isDirectory: &isDir)
        return isDir.boolValue
    }

    mutating func mkdir() {
        if isDirectory() {
            return
        }
        try! NSFileManager.defaultManager().createDirectoryAtPath(self.path, withIntermediateDirectories: false, attributes: nil)
        fixPathIfNeeded()
    }

    mutating func mkdirs() {
        if isDirectory() {
            return
        }
        try! NSFileManager.defaultManager().createDirectoryAtPath(self.path, withIntermediateDirectories: true, attributes: nil)
        fixPathIfNeeded()
    }

    func getName() -> String {
        return self.path.characters.split(Character("/")).map { String($0) }.last!
    }

    func list() throws -> [String] {
        return try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.path)
    }

    func move(toFile toFile: File) -> Bool {
        do {
            try NSFileManager.defaultManager().moveItemAtPath(self.path, toPath: toFile.path)
        } catch {
            return false
        }
        return true
    }

    func delete() -> Bool {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(self.path)
        } catch {
            return false
        }
        return true
    }

    func listFiles() throws -> [File] {
        let files = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.path)
        return files.map { try! File(dir: self, name: $0 ) }
    }

    static let docFile = File(path: try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).path!)
}

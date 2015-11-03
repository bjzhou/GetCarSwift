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
        try! NSFileManager.defaultManager().createDirectoryAtPath(self.path, withIntermediateDirectories: false, attributes: nil)
        fixPathIfNeeded()
    }

    mutating func mkdirs() {
        try! NSFileManager.defaultManager().createDirectoryAtPath(self.path, withIntermediateDirectories: true, attributes: nil)
        fixPathIfNeeded()
    }

    func getName() -> String {
        return self.path.characters.split(Character("/")).map { String($0) }.last!
    }

    func list() -> [File]? {
        let files = NSFileManager.defaultManager().enumeratorAtPath(self.path)
        return files?.filter { ($0 as? String) != nil }.map { File(path: $0 as! String) }
    }

    static let docFile = File(path: try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true).path!)
}
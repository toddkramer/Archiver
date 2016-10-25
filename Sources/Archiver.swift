//
//  Archiver.swift
//
//  Copyright (c) 2016 Todd Kramer (http://www.tekramer.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

open class Archiver {

    public static let `default` = Archiver()

    static let bundleNameKey: String = kCFBundleNameKey as String
    static let targetName: String = Bundle.main.infoDictionary?[bundleNameKey] as? String ?? "UnknownApp"
    static let cachesDirectoryURL: URL? = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    static let defaultDirectoryName: String = "com.\(targetName).archives"
    static let defaultDirectoryURL: URL? = cachesDirectoryURL?.appendingPathComponent(defaultDirectoryName)

    let fileManager: FileManager = .default

    public class var rootDirectoryURL: URL? {
        get { return Archiver.default.rootDirectoryURL }
        set { Archiver.default.rootDirectoryURL = newValue }
    }

    public class var archiveDirectoryName: String {
        get { return Archiver.default.archiveDirectoryName }
        set { Archiver.default.archiveDirectoryName = newValue }
    }

    var rootDirectoryURL: URL? = Archiver.cachesDirectoryURL {
        didSet { resetArchiveDirectoryURL() }
    }
    var archiveDirectoryName: String = Archiver.defaultDirectoryName {
        didSet { resetArchiveDirectoryURL() }
    }

    public private(set) var archiveDirectoryURL: URL?

    public init(archiveDirectoryURL: URL? = defaultDirectoryURL) {
        self.archiveDirectoryURL = archiveDirectoryURL
    }

    func resetArchiveDirectoryURL() {
        archiveDirectoryURL = rootDirectoryURL?.appendingPathComponent(archiveDirectoryName)
    }

    func createDirectoryIfNeeded(atPath path: String) {
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                print("WARNING: Archive directory creation failed!")
            }
        }
    }

    func store(archive: Archive, atPath path: String) {
        let success = NSKeyedArchiver.archiveRootObject(archive, toFile: path)
        if !success {
            print("WARNING: Property list creation failed!")
        }
    }

    func archive(atPath path: String) -> Archive? {
        guard fileManager.fileExists(atPath: path) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(withFile: path) as? Archive
    }

    public func clearAll() {
        guard let path = archiveDirectoryURL?.path else { return }
        deleteArchive(atPath: path)
    }

    func deleteArchive(atPath path: String) {
        guard FileManager.default.fileExists(atPath: path) else { return }
        do {
            try FileManager.default.removeItem(atPath: path)
        }
        catch {
            print("WARNING: Archive deletion failed!")
        }
    }

}

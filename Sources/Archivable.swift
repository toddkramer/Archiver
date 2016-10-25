//
//  Archivable.swift
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

public typealias Archive = [String: Any]

public protocol Archivable: ArchiveRepresentable, UniquelyIdentifiable {

    static var archiver: Archiver { get }
    static var directoryName: String { get }

    init?(resourceID: String)

    func storeArchive()
    func deleteArchive()

}

extension Archivable {

    public static var archiver: Archiver { return .default }
    public static var directoryName: String {
        return String(describing: self)
    }
    static var directoryURL: URL? {
        return archiver.archiveDirectoryURL?.appendingPathComponent(directoryName)
    }
    var fileURL: URL? {
        return Self.directoryURL?.appendingPathComponent("\(id).plist")
    }

    public init?(resourceID: String) {
        let url = Self.directoryURL?.appendingPathComponent("\(resourceID).plist")
        guard let path = url?.path else { return nil }
        guard let archive = Self.archiver.archive(atPath: path) else { return nil }
        self.init(archive: archive)
    }

    public func storeArchive() {
        guard let directoryPath = Self.directoryURL?.path else { return }
        Self.archiver.createDirectoryIfNeeded(atPath: directoryPath)
        guard let path = fileURL?.path else { return }
        Self.archiver.store(archive: archiveValue, atPath: path)
    }

    public func deleteArchive() {
        guard let path = fileURL?.path else { return }
        Self.archiver.deleteArchive(atPath: path)
    }

}

extension Archivable {

    public static func unarchivedCollection(withIdentifiers identifiers: [String]) -> [Self] {
        return identifiers.flatMap { Self(resourceID: $0) }
    }

}

extension Array where Element: Archivable {

    public func storeArchives() {
        forEach { $0.storeArchive() }
    }

}

//
//  Cachable.swift
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

public protocol Cachable: Archivable, Serializable {

    init?(responseObject: ResponseObject, shouldArchive: Bool)

}

extension Cachable {

    public init?(responseObject: ResponseObject, shouldArchive: Bool) {
        self.init(responseObject: responseObject)
        if !shouldArchive { return }
        storeArchive()
    }

}

extension Cachable {

    public static func archivedCollection(from responseObject: ResponseObject, withKey key: String) -> [Self] {
        guard let responseObjects = responseObject[key] as? [ResponseObject] else { return [Self]() }
        return archivedCollection(from: responseObjects)
    }

    public static func archivedCollection(from responseObjects: [ResponseObject]) -> [Self] {
        return responseObjects.flatMap { Self(responseObject: $0, shouldArchive: true) }
    }

}

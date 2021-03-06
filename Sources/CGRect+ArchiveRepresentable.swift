//
//  CGRect+ArchiveRepresentable.swift
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
import CoreGraphics

extension CGRect: ArchiveRepresentable {

    private struct Key {
        static let origin = "origin"
        static let size = "size"
    }

    public var archiveValue: Archive {
        return [
            Key.origin: origin.archiveValue,
            Key.size: size.archiveValue
        ]
    }

    public init(archive: Archive) {
        guard let origin = archive[Key.origin] as? Archive,
            let size = archive[Key.size] as? Archive else {
                self = .zero
                return
        }
        self.origin = CGPoint(archive: origin)
        self.size = CGSize(archive: size)
    }

}

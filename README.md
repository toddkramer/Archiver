# Archiver

![CocoaPods Version](https://cocoapod-badges.herokuapp.com/v/Archiver.swift/badge.png) [![Swift](https://img.shields.io/badge/swift-3-orange.svg?style=flat)](https://developer.apple.com/swift/) ![Platform](https://cocoapod-badges.herokuapp.com/p/Archiver.swift/badge.png) [![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A protocol-oriented framework for serializing and archiving Swift value types.

- [Tutorial](#tutorial)
- [Usage](#usage)
    - [Serialization](#serialization)
    - [Archiving](#archiving)
    - [Caching](#caching)
- [Installation](#installation)


## Tutorial

A full tutorial showing an example usage of Archiver is available [here](http://www.tekramer.com/serializing-archiving-structs-in-swift-with-archiver/).

## Usage

### Serialization

One of the main use cases for Archiver is to archive value types that are created with data from a server. The first step in archiving this data is serialization.

*Serializable Protocol*

```swift
extension Restaurant: Serializable {

    private struct ServerKey {
        static let id = "id"
        static let name = "name"
    }

    public init?(responseObject: ResponseObject) {
        guard let id = responseObject[ServerKey.id] as? String else { return nil }
        guard let name = responseObject[ServerKey.name] as? String else { return nil }
        self.id = id
        self.name = name
    }

}
```

Notes:

1. `ResponseObject` is a type alias for `[String: Any]`.

2. The Serializable protocol's initializer requirement is failable, but your implementation of it does not have to be. The Restaurant initializer could have been implemented as follows:

```swift
public init(responseObject: ResponseObject) {
    self.id = responseObject[ServerKey.id] as? String ?? ""
    self.name = responseObject[ServerKey.name] as? String ?? ""
}
```

*Serialization Utilities*

Archiver includes utility functions for serializing collections of response objects.

Example JSON:

```swift
let restaurantsJSON = [
    "restaurants": [
        ["id": "abcd-1234",
         "name": "Masala Mansion"
        ],
        ["id": "efgh-5678",
         "name": "Empanada Estancia"
        ],
        ["id": "ijkl-9012",
         "name": "Charcuterie Chateau"
        ]
    ]
]
```

To serialize this into a collection of Restaurant values:

```swift
let restaurants = Restaurant.serializedCollection(from: restaurantsJSON, withKey: "restaurants")
```

If your JSON is an array of response objects:

```swift
let restaurantsJSON = [
    ["id": "abcd-1234",
     "name": "Masala Mansion"
    ],
    ["id": "efgh-5678",
     "name": "Empanada Estancia"
    ],
    ["id": "ijkl-9012",
     "name": "Charcuterie Chateau"
    ]
]
```

```swift
let restaurants = Restaurant.serializedCollection(from: restaurantsJSON)
```

To serialize a single dictionary response object:

```swift
let restaurantJSON = [
    "restaurant": [
        "id": "abcd-1234",
        "name": "Masala Mansion"
    ]
]
```

```swift
let restaurant = Restaurant.serialized(from: restaurantJSON, withKey: "restaurant")
```

### Archiving

Archiver uses two protocols to implement archiving. The first is ArchiveRepresentable, which requires that conforming types supply NSCoding-compliant representations of themselves and be initializable from an archive. This allows conforming types to be included in an archive.

The second protocol is Archivable, which inherits from ArchiveRepresentable. Archivable manages saving the archive as a property list to disk and deleting the archive if needed.

*ArchiveRepresentable Protocol*

```swift
extension Restaurant: ArchiveRepresentable {

    private struct ArchiveKey {
        static let id = "id"
        static let name = "name"
    }

    public var archiveValue: Archive {
        return [
            ArchiveKey.id: id,
            ArchiveKey.name: name
        ]
    }

    public init?(archive: Archive) {
        guard let id = archive[ArchiveKey.id] as? String else { return nil }
        guard let name = archive[ArchiveKey.name] as? String else { return nil }
        self.id = id
        self.name = name
    }

}
```

Notes:

1. `Archive` is a type alias for `[String: Any]`.

2. The ArchiveRepresentable protocol's initializer requirement is failable, but your implementation of it does not have to be. The Restaurant initializer could have been implemented as follows:

```swift
public init(archive: Archive) {
    self.id = archive[ArchiveKey.id] as? String ?? ""
    self.name = archive[ArchiveKey.name] as? String ?? ""
}
```

*Archivable Protocol*

Archivable inherits from two other protocols, ArchiveRepresentable and UniquelyIdentifiable. ArchiveRepresentable is described above.

Uniquely identifiable has only one requirement, that conforming types have a unique `id` property. UniquelyIdentifiable also conforms to Equatable.

Archivable's requirements all have default implementations. Since the `Restaurant` example already conforms to UniquelyIdentifiable and ArchiveRepresentable, it already conforms to `Archivable` as well.

```swift
extension Restaurant: Archivable
```

To unarchive a conforming type:

```swift
guard let restaurant = Restaurant(resourceID: "abcd-1234") else { return }
```

Notes:

1. An archive with a given resourceID may not exist, so this initializer returns an optional.

2. Archivable includes a default implementation of this initializer. You do not need to provide your own.

To store an archive:

```swift
restaurant.storeArchive()
```

To delete an archive:

```swift
restaurant.deleteArchive()
```

`storeArchive()` and `deleteArchive()` are also requirements with default implementations.

*Archiving Utilities*

Archiver includes utility functions for archiving collections.

To get an array of archive values for a collection:

```swift
restaurants.archiveValue
```

To store a collection of Archivable values:

```swift
restaurants.storeArchives()
```

To unarchive a collection of Archivable values or objects:

```swift
Restaurant.unarchivedCollection(withIdentifiers: ["abcd-1234", "efgh-5678", "ijkl-9012"])
```

To unarchive a collection of ArchiveRepresentable values from an Archive with a key:

```swift
Restaurant.unarchivedCollection(from: archive, withKey: ArchiveKey.restaurants)
```

To unarchive a collection of ArchiveRepresentable values without a key:

```swift
Restaurant.unarchivedCollection(from: archives)
```

To unarchive a single ArchiveRepresentable value:

```swift
guard let restaurant = Restaurant.unarchived(from: archive, withKey: ArchiveKey.restaurant) else { return }
```

*Archive Location*

By default, Archiver uses your device's Caches directory as the root and creates a subdirectory for your app's archives using your app's `CFBundleName`.

This results in a default location of `Library/Caches/com.BundleName.archives`.

To set the root directory:
```swift
if let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
    Archiver.rootDirectoryURL = documentsDirectoryURL
}
```

To set the archive directory name:

```swift
Archiver.archiveDirectoryName = "com.CustomName.archives"
```

Archiver also creates a subdirectory for each custom type. By default this is the type name. For example, a "User" type would be stored at `Library/Caches/com.BundleName.archives/User` by default. To set a custom subdirectory name, you can override the `directoryName` static variable from the Archivable protocol.

```swift
extension Restaurant: Archivable {

    static var directoryName: String {
        return "RestaurantArchives"
    }

}
```

### Caching

Types that are both serializable and archivable can be cached. Caching is the full process of taking a server response object, serializing it into a value type, and archiving that value to disk.

*Cachable Protocol*

To cache a response object:

```swift
guard let restaurant = Restaurant(responseObject: json, shouldArchive: true) else { return }
```

Notes:

1. Cachable includes a default implementation of this initializer. You do not need to provide your own. For types that already conform to Serializable and Archivable, simplify declare conformance to Cachable:

    ```swift
    extension Restaurant: Cachable
    ```


## Installation

> _Note:_ Archiver requires Swift 3 (and [Xcode][] 8) or greater.
>
> Targets using Archiver must support embedded Swift frameworks.

[Xcode]: https://developer.apple.com/xcode/downloads/

### Swift Package Manager

[Swift Package Manager](https://github.com/apple/swift-package-manager) is Apple's
official package manager for Swift frameworks. To install with Swift Package
Manager:

1. Add Archiver to your Package.swift file:

    ```
    import PackageDescription

    let package = Package(
        name: "MyAppTarget",
        dependencies: [
            .Package(url: "https://github.com/toddkramer/Archiver",
                     majorVersion: 0, minor: 6)
        ]
    )
    ```

2. Run `swift build`.

3. Generate Xcode project:

    ```
    swift package generate-xcodeproj
    ```


### Carthage

[Carthage][] is a decentralized dependency manager for Cocoa projects. To
install Archiver with Carthage:

 1. Make sure Carthage is [installed][Carthage Installation].

 2. Add Archiver to your Cartfile:

    ```
    github "toddkramer/Archiver" ~> 0.6.1
    ```

 3. Run `carthage update` and [add the appropriate framework][Carthage Usage].


[Carthage]: https://github.com/Carthage/Carthage
[Carthage Installation]: https://github.com/Carthage/Carthage#installing-carthage
[Carthage Usage]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application


### CocoaPods

[CocoaPods][] is a centralized dependency manager for Cocoa projects. To install
Archiver with CocoaPods:

 1. Make sure the latest version of CocoaPods is [installed](https://guides.cocoapods.org/using/getting-started.html#getting-started).


 2. Add Archiver.swift to your Podfile:

    ``` ruby
    use_frameworks!

    pod 'Archiver.swift', '~> 0.6.1'
    ```

 3. Run `pod install`.

[CocoaPods]: https://cocoapods.org


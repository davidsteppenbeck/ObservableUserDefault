# ObservableUserDefault

`ObservableUserDefault` is a Swift macro for properties in `@Observable` classes that provides accessor blocks with getters and setters that read and write the properties in `UserDefaults`.

## Usage

Note that the `@ObservationIgnored` annotation is necessary when using `@ObservableUserDefault` owing to the way that `@Observable` works: Without it, the `@Observable` macro will inject its own getters and setters in the accessor block and the macros will conflict, causing errors.

```swift
import ObservableUserDefault

@Observable
final class StorageModel {
    @ObservableUserDefault
    @ObservationIgnored
    var name: String
}
```

This will automatically generate the following code:

```swift
@Observable
final class StorageModel {
    var name: String {
        get {
            access(keyPath: \.name)
            return UserDefaults.name
        }
        set {
            withMutation(keyPath: \.name) {
                UserDefaults.name = newValue
            }
        }
    }
}
```

## Installation

The package can be installed using [Swift Package Manager](https://swift.org/package-manager/). To add ObservableUserDefault to your Xcode project, select *File > Add Package Dependancies...* and search for the repository URL: `https://github.com/davidsteppenbeck/ObservableUserDefault`.

## License

ObservableUserDefault is available under the MIT license. See the LICENSE file for more info.

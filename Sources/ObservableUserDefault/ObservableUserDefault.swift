import Foundation

/// An attached macro for properties in `@Observable` classes that provides accessor blocks with getters and setters that read and write the properties in `UserDefaults`.
/// Applying the macro to anything other than a `var` without an accessor block will result in a compile time error.
///
/// The macro can be used with or without an explicit argument.
///
/// When an explicit argument is provided, the macro will use the storage key, default value, and `UserDefaults` store to generate the expanded macro code,
/// otherwise the macro will provide a static property on `UserDefaults` with the same name as the variable that the macro is attached to.
///
/// For example, applying `@ObservableUserDefault` to an `@ObservationIgnored` property inside an `@Observable` class
///
///     @Observable
///     final class StorageModel {
///         @ObservableUserDefault
///         @ObservationIgnored
///         var name: String
///     }
///
/// results in the following code automatically
///
///     @Observable
///     final class StorageModel {
///         @ObservationIgnored
///         var name: String {
///             get {
///                 access(keyPath: \.name)
///                 return UserDefaults.name
///             }
///             set {
///                 withMutation(keyPath: \.name) {
///                     UserDefaults.name = newValue
///                 }
///             }
///         }
///     }
///
/// Explicit arguments can be provided to the macro if you want to use specific keys, default values, and `UserDefaults` suites.
/// When the macro is attached to non-optional types, the arguments must include default values, for example
///
///     @Observable
///     final class StorageModel {
///         @ObservableUserDefault(.init(key: "NAME_STORAGE_KEY", defaultValue: "John Appleseed", store: .standard))
///         @ObservationIgnored
///         var name: String
///     }
///
/// results in the following code automatically
///
///     @Observable
///     final class StorageModel {
///         @ObservationIgnored
///         var name: String {
///             get {
///                 access(keyPath: \.name)
///                 return UserDefaults.standard.value(forKey: "NAME_STORAGE_KEY") as? String ?? "John Appleseed"
///             }
///             set {
///                 withMutation(keyPath: \.name) {
///                     UserDefaults.standard.set(newValue, forKey: "NAME_STORAGE_KEY")
///                 }
///             }
///         }
///     }
///
/// When the macro is attached to optional types, default values should be omitted from arguments, for example
///
///     @Observable
///     final class StorageModel {
///         @ObservableUserDefault(.init(key: "DATE_STORAGE_KEY", store: .standard))
///         @ObservationIgnored
///         var date: Date?
///     }
///
/// results in the following code automatically
///
///     @Observable
///     final class StorageModel {
///         @ObservationIgnored
///         var date: Date? {
///             get {
///                 access(keyPath: \.date)
///                 return UserDefaults.standard.value(forKey: "DATE_STORAGE_KEY") as? Date
///             }
///             set {
///                 withMutation(keyPath: \.date) {
///                     UserDefaults.standard.set(newValue, forKey: "DATE_STORAGE_KEY")
///                 }
///             }
///         }
///     }
///
/// Note that the `@ObservationIgnored` annotation is necessary when using `@ObservableUserDefault` owing to the way that `@Observable` works:
/// Without it, the `@Observable` macro will inject its own getters and setters in the accessor block and the macros will conflict, causing errors.
@attached(accessor, names: named(get), named(set))
public macro ObservableUserDefault() = #externalMacro(
    module: "ObservableUserDefaultMacros",
    type: "ObservableUserDefaultMacro"
)

/// An attached macro for properties in `@Observable` classes that provides accessor blocks with getters and setters that read and write the properties in `UserDefaults`.
/// Applying the macro to anything other than a `var` without an accessor block will result in a compile time error.
///
/// The macro can be used with or without an explicit argument.
///
/// When an explicit argument is provided, the macro will use the storage key, default value, and `UserDefaults` store to generate the expanded macro code,
/// otherwise the macro will provide a static property on `UserDefaults` with the same name as the variable that the macro is attached to.
///
/// For example, applying `@ObservableUserDefault` to an `@ObservationIgnored` property inside an `@Observable` class
///
///     @Observable
///     final class StorageModel {
///         @ObservableUserDefault
///         @ObservationIgnored
///         var name: String
///     }
///
/// results in the following code automatically
///
///     @Observable
///     final class StorageModel {
///         @ObservationIgnored
///         var name: String {
///             get {
///                 access(keyPath: \.name)
///                 return UserDefaults.name
///             }
///             set {
///                 withMutation(keyPath: \.name) {
///                     UserDefaults.name = newValue
///                 }
///             }
///         }
///     }
///
/// Explicit arguments can be provided to the macro if you want to use specific keys, default values, and `UserDefaults` suites.
/// When the macro is attached to non-optional types, the arguments must include default values, for example
///
///     @Observable
///     final class StorageModel {
///         @ObservableUserDefault(.init(key: "NAME_STORAGE_KEY", defaultValue: "John Appleseed", store: .standard))
///         @ObservationIgnored
///         var name: String
///     }
///
/// results in the following code automatically
///
///     @Observable
///     final class StorageModel {
///         @ObservationIgnored
///         var name: String {
///             get {
///                 access(keyPath: \.name)
///                 return UserDefaults.standard.value(forKey: "NAME_STORAGE_KEY") as? String ?? "John Appleseed"
///             }
///             set {
///                 withMutation(keyPath: \.name) {
///                     UserDefaults.standard.set(newValue, forKey: "NAME_STORAGE_KEY")
///                 }
///             }
///         }
///     }
///
/// When the macro is attached to optional types, default values should be omitted from arguments, for example
///
///     @Observable
///     final class StorageModel {
///         @ObservableUserDefault(.init(key: "DATE_STORAGE_KEY", store: .standard))
///         @ObservationIgnored
///         var date: Date?
///     }
///
/// results in the following code automatically
///
///     @Observable
///     final class StorageModel {
///         @ObservationIgnored
///         var date: Date? {
///             get {
///                 access(keyPath: \.date)
///                 return UserDefaults.standard.value(forKey: "DATE_STORAGE_KEY") as? Date
///             }
///             set {
///                 withMutation(keyPath: \.date) {
///                     UserDefaults.standard.set(newValue, forKey: "DATE_STORAGE_KEY")
///                 }
///             }
///         }
///     }
///
/// Note that the `@ObservationIgnored` annotation is necessary when using `@ObservableUserDefault` owing to the way that `@Observable` works:
/// Without it, the `@Observable` macro will inject its own getters and setters in the accessor block and the macros will conflict, causing errors.
@attached(accessor, names: named(get), named(set))
public macro ObservableUserDefault<DefaultValue>(_ metadata: ObservableUserDefaultMetadata<DefaultValue>) = #externalMacro(
    module: "ObservableUserDefaultMacros",
    type: "ObservableUserDefaultMacro"
)

/// Use as an argument to the `ObservableUserDefault` macro when attached to non-optional types that require a default value.
public struct ObservableUserDefaultMetadata<DefaultValue> {
    let key: String
    let defaultValue: DefaultValue
    let store: UserDefaults
    
    public init(key: String, defaultValue: DefaultValue, store: UserDefaults) {
        self.key = key
        self.defaultValue = defaultValue
        self.store = store
    }
}

/// An attached macro for properties in `@Observable` classes that provides accessor blocks with getters and setters that read and write the properties in `UserDefaults`.
/// Applying the macro to anything other than a `var` without an accessor block will result in a compile time error.
///
/// The macro can be used with or without an explicit argument.
///
/// When an explicit argument is provided, the macro will use the storage key, default value, and `UserDefaults` store to generate the expanded macro code,
/// otherwise the macro will provide a static property on `UserDefaults` with the same name as the variable that the macro is attached to.
///
/// For example, applying `@ObservableUserDefault` to an `@ObservationIgnored` property inside an `@Observable` class
///
///     @Observable
///     final class StorageModel {
///         @ObservableUserDefault
///         @ObservationIgnored
///         var name: String
///     }
///
/// results in the following code automatically
///
///     @Observable
///     final class StorageModel {
///         @ObservationIgnored
///         var name: String {
///             get {
///                 access(keyPath: \.name)
///                 return UserDefaults.name
///             }
///             set {
///                 withMutation(keyPath: \.name) {
///                     UserDefaults.name = newValue
///                 }
///             }
///         }
///     }
///
/// Explicit arguments can be provided to the macro if you want to use specific keys, default values, and `UserDefaults` suites.
/// When the macro is attached to non-optional types, the arguments must include default values, for example
///
///     @Observable
///     final class StorageModel {
///         @ObservableUserDefault(.init(key: "NAME_STORAGE_KEY", defaultValue: "John Appleseed", store: .standard))
///         @ObservationIgnored
///         var name: String
///     }
///
/// results in the following code automatically
///
///     @Observable
///     final class StorageModel {
///         @ObservationIgnored
///         var name: String {
///             get {
///                 access(keyPath: \.name)
///                 return UserDefaults.standard.value(forKey: "NAME_STORAGE_KEY") as? String ?? "John Appleseed"
///             }
///             set {
///                 withMutation(keyPath: \.name) {
///                     UserDefaults.standard.set(newValue, forKey: "NAME_STORAGE_KEY")
///                 }
///             }
///         }
///     }
///
/// When the macro is attached to optional types, default values should be omitted from arguments, for example
///
///     @Observable
///     final class StorageModel {
///         @ObservableUserDefault(.init(key: "DATE_STORAGE_KEY", store: .standard))
///         @ObservationIgnored
///         var date: Date?
///     }
///
/// results in the following code automatically
///
///     @Observable
///     final class StorageModel {
///         @ObservationIgnored
///         var date: Date? {
///             get {
///                 access(keyPath: \.date)
///                 return UserDefaults.standard.value(forKey: "DATE_STORAGE_KEY") as? Date
///             }
///             set {
///                 withMutation(keyPath: \.date) {
///                     UserDefaults.standard.set(newValue, forKey: "DATE_STORAGE_KEY")
///                 }
///             }
///         }
///     }
///
/// Note that the `@ObservationIgnored` annotation is necessary when using `@ObservableUserDefault` owing to the way that `@Observable` works:
/// Without it, the `@Observable` macro will inject its own getters and setters in the accessor block and the macros will conflict, causing errors.
@attached(accessor, names: named(get), named(set))
public macro ObservableUserDefault(_ metadata: ObservableOptionalUserDefaultMetadata) = #externalMacro(
    module: "ObservableUserDefaultMacros",
    type: "ObservableUserDefaultMacro"
)

/// Use as an argument to the `ObservableUserDefault` macro when attached to optional types that do not require a default value.
public struct ObservableOptionalUserDefaultMetadata {
    let key: String
    let store: UserDefaults
    
    public init(key: String, store: UserDefaults) {
        self.key = key
        self.store = store
    }
}

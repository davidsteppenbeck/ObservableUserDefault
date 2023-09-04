/// An attached macro for properties in `@Observable` classes that provides accessor blocks with getters and setters that read and write the properties in `UserDefaults`.
/// Applying the macro to anything other than a `var` without an accessor block will result in a compile time error.
///
/// Applying `@ObservableUserDefault` to a `@ObservationIgnored var` inside an `@Observable` class
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
/// Note that the `@ObservationIgnored` annotation is necessary when using `@ObservableUserDefault` owing to the way that `@Observable` works:
/// Without it, the `@Observable` macro will inject its own getters and setters in the accessor block and the macros will conflict, causing errors.
@attached(accessor)
public macro ObservableUserDefault() = #externalMacro(module: "ObservableUserDefaultMacros", type: "ObservableUserDefaultMacro")

import SwiftUI
import ObservableUserDefault

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, macCatalyst 17.0, visionOS 1.0, *)
@Observable final class Person {
    
    // Use without arguments to access static properties, for example, `UserDefaults.name`.
    @ObservableUserDefault
    @ObservationIgnored
    var name: String
    
    // Use arguments containing default values when attached to non-optional types.
    @ObservableUserDefault(.init(key: "ADDRESS_STORAGE_KEY_EXAMPLE", defaultValue: "One Infinite Loop", store: .standard))
    @ObservationIgnored
    var address: String
    
    // Use custom `UserDefaults` suites by specifying the store name.
    @ObservableUserDefault(.init(key: "NUMBER_STORAGE_KEY_EXAMPLE", defaultValue: Int.zero, store: .shared))
    @ObservationIgnored
    var number: Int
    
    // Use arguments containing no default values when attached to optional types.
    @ObservableUserDefault(.init(key: "DATE_STORAGE_KEY_EXAMPLE", store: .standard))
    @ObservationIgnored
    var date: Date?
    
}

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "SHARED_SUITE_EXAMPLE")!
    static var name: String = "John Appleseed"
}

/*
import SwiftUI
import ObservableUserDefault

@Observable
class Person {
    
    @ObservableUserDefault
    @ObservationIgnored
    var name: String
    
    @ObservableUserDefault(.init(key: "ADDRESS_STORAGE_KEY", defaultValue: "One Infinite Loop", store: .standard))
    @ObservationIgnored
    var address: String
    
    @ObservableUserDefault(.init(key: "NUMBER_STORAGE_KEY", defaultValue: Int.zero, store: .shared))
    @ObservationIgnored
    var number: Int
    
}

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "shared_suite_example")!
    static var name: String = "John Appleseed"
}
*/

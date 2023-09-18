import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ObservableUserDefaultMacros)
import ObservableUserDefaultMacros

let testMacros: [String: Macro.Type] = [
    "ObservableUserDefault": ObservableUserDefaultMacro.self,
]
#endif

final class ObservableUserDefaultTests: XCTestCase {
    
    func testObservableUserDefault() throws {
        #if canImport(ObservableUserDefaultMacros)
        assertMacroExpansion(
            #"""
            @Observable
            class StorageModel {
                @ObservableUserDefault
                @ObservationIgnored
                var name: String
            }
            """#,
            expandedSource:
            #"""
            @Observable
            class StorageModel {
                @ObservationIgnored
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
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testObservableUserDefaultWithArgumentOnNonOptionalType() throws {
        #if canImport(ObservableUserDefaultMacros)
        assertMacroExpansion(
            #"""
            @Observable
            class StorageModel {
                @ObservableUserDefault(.init(key: "NUMBER_STORAGE_KEY", defaultValue: 1000, store: .standard))
                @ObservationIgnored
                var number: Int
            }
            """#,
            expandedSource:
            #"""
            @Observable
            class StorageModel {
                @ObservationIgnored
                var number: Int {
                    get {
                        access(keyPath: \.number)
                        return UserDefaults.standard.value(forKey: "NUMBER_STORAGE_KEY") as? Int ?? 1000
                    }
                    set {
                        withMutation(keyPath: \.number) {
                            UserDefaults.standard.set(newValue, forKey: "NUMBER_STORAGE_KEY")
                        }
                    }
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testObservableUserDefaultWithIncorrectArgumentOnNonOptionalType() throws {
        #if canImport(ObservableUserDefaultMacros)
        assertMacroExpansion(
            #"""
            @Observable
            class StorageModel {
                @ObservableUserDefault(.init(key: "NUMBER_STORAGE_KEY", store: .standard))
                @ObservationIgnored
                var number: Int
            }
            """#,
            expandedSource:
            #"""
            @Observable
            class StorageModel {
                @ObservationIgnored
                var number: Int
            }
            """#,
            diagnostics: [
                DiagnosticSpec(message: "'@ObservableUserDefault' arguments on non-optional types must provide default values", line: 3, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testObservableUserDefaultWithArgumentOnOptionalType() throws {
        #if canImport(ObservableUserDefaultMacros)
        assertMacroExpansion(
            #"""
            @Observable
            class StorageModel {
                @ObservableUserDefault(.init(key: "NUMBER_STORAGE_KEY", store: .standard))
                @ObservationIgnored
                var number: Int?
            }
            """#,
            expandedSource:
            #"""
            @Observable
            class StorageModel {
                @ObservationIgnored
                var number: Int? {
                    get {
                        access(keyPath: \.number)
                        return UserDefaults.standard.value(forKey: "NUMBER_STORAGE_KEY") as? Int
                    }
                    set {
                        withMutation(keyPath: \.number) {
                            UserDefaults.standard.set(newValue, forKey: "NUMBER_STORAGE_KEY")
                        }
                    }
                }
            }
            """#,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testObservableUserDefaultWithIncorrectArgumentOnOptionalType() throws {
        #if canImport(ObservableUserDefaultMacros)
        assertMacroExpansion(
            #"""
            @Observable
            class StorageModel {
                @ObservableUserDefault(.init(key: "NUMBER_STORAGE_KEY", defaultValue: 1000, store: .standard))
                @ObservationIgnored
                var number: Int?
            }
            """#,
            expandedSource:
            #"""
            @Observable
            class StorageModel {
                @ObservationIgnored
                var number: Int?
            }
            """#,
            diagnostics: [
                DiagnosticSpec(message: "'@ObservableUserDefault' arguments on optional types should not use default values", line: 3, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testObservableUserDefaultWithConstant() throws {
        #if canImport(ObservableUserDefaultMacros)
        assertMacroExpansion(
            """
            @Observable
            class StorageModel {
                @ObservableUserDefault
                @ObservationIgnored
                let name: String
            }
            """,
            expandedSource:
            """
            @Observable
            class StorageModel {
                @ObservationIgnored
                let name: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@ObservableUserDefault' can only be applied to variables", line: 3, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testObservableUserDefaultWithComputedProperty() throws {
        #if canImport(ObservableUserDefaultMacros)
        assertMacroExpansion(
            """
            @Observable
            class StorageModel {
                @ObservableUserDefault
                @ObservationIgnored
                var name: String {
                    return "John Appleseed"
                }
            }
            """,
            expandedSource:
            """
            @Observable
            class StorageModel {
                @ObservationIgnored
                var name: String {
                    return "John Appleseed"
                }
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@ObservableUserDefault' cannot be applied to computed properties", line: 2, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testObservableUserDefaultWithStoredProperty() throws {
        #if canImport(ObservableUserDefaultMacros)
        assertMacroExpansion(
            """
            @Observable
            class StorageModel {
                @ObservableUserDefault
                @ObservationIgnored
                var name: String = "John Appleseed"
            }
            """,
            expandedSource:
            """
            @Observable
            class StorageModel {
                @ObservationIgnored
                var name: String = "John Appleseed"
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@ObservableUserDefault' cannot be applied to stored properties", line: 3, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
}

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
            class StorageModel {
                @ObservableUserDefault
                var name: String
            }
            """#,
            expandedSource:
            #"""
            class StorageModel {
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
    
    func testObservableUserDefaultOnConstant() throws {
        #if canImport(ObservableUserDefaultMacros)
        assertMacroExpansion(
            """
            class StorageModel {
                @ObservableUserDefault
                let name: String
            }
            """,
            expandedSource:
            """
            class StorageModel {
                let name: String
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "'@ObservableUserDefault' can only be applied to variables", line: 2, column: 5)
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
}

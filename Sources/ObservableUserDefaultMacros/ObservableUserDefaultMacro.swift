import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObservableUserDefaultMacro: AccessorMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        // Ensure the macro can only be attached to variable properties.
        guard let varDecl = declaration.as(VariableDeclSyntax.self), varDecl.bindingSpecifier.text == "var" else {
            throw ObservableUserDefaultError.notVariableProperty
        }
        
        // Ensure the variable is defines a single property declaration, for example,
        // `var name: String` and not multiple declarations such as `var name, address: String`.
        guard varDecl.bindings.count == 1, let binding = varDecl.bindings.first else {
            throw ObservableUserDefaultError.propertyMustContainOnlyOneBinding
        }
        
        // Ensure there is no computed property block attached to the variable already.
        guard binding.accessorBlock == nil else {
            throw ObservableUserDefaultError.propertyMustHaveNoAccessorBlock
        }
        
        // For simple variable declarations, the binding pattern is `IdentifierPatternSyntax`,
        // which defines the name of a single variable.
        guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            throw ObservableUserDefaultError.propertyMustUseSimplePatternSyntax
        }
        
        return [
        #"""
        get {
            access(keyPath: \.\#(pattern.identifier))
            return UserDefaults.\#(pattern.identifier)
        }
        """#,
        #"""
        set {
            withMutation(keyPath: \.\#(pattern.identifier)) {
                UserDefaults.\#(pattern.identifier) = newValue
            }
        }
        """#
        ]
    }
    
}

enum ObservableUserDefaultError: Error, CustomStringConvertible {
    case notVariableProperty
    case propertyMustContainOnlyOneBinding
    case propertyMustHaveNoAccessorBlock
    case propertyMustUseSimplePatternSyntax
    
    var description: String {
        switch self {
        case .notVariableProperty:
            return "'@ObservableUserDefault' can only be applied to variables"
        case .propertyMustContainOnlyOneBinding:
            return "'@ObservableUserDefault' cannot be applied to multiple variable bindings"
        case .propertyMustHaveNoAccessorBlock:
            return "'@ObservableUserDefault' cannot be applied to computed properties"
        case .propertyMustUseSimplePatternSyntax:
            return "'@ObservableUserDefault' can only be applied to a variables using simple declaration syntax, for example, 'var name: String'"
        }
    }
}

@main
struct ObservableUserDefaultPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObservableUserDefaultMacro.self
    ]
}

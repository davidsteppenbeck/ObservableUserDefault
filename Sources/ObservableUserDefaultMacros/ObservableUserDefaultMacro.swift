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
        guard let varDecl = declaration.as(VariableDeclSyntax.self), varDecl.bindingSpecifier.tokenKind == .keyword(.var) else {
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
        
        // Ensure there is no initial value assigned to the variable.
        guard binding.initializer == nil else {
            throw ObservableUserDefaultError.propertyMustHaveNoInitializer
        }
        
        // For simple variable declarations, the binding pattern is `IdentifierPatternSyntax`,
        // which defines the name of a single variable.
        guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            throw ObservableUserDefaultError.propertyMustUseSimplePatternSyntax
        }
        
        // Check if there is an explicit argument provided to the macro.
        // If so, extract the key, defaultValue, and store to use, and provide stored properties from `UserDefaults` that use the values extracted from the macro argument.
        // If not, use a static property on `UserDefaults` with the same name as the property.
        guard let arguments = node.arguments else {
            return [
            #"""
            get {
                access(keyPath: \.\#(pattern))
                return UserDefaults.\#(pattern)
            }
            """#,
            #"""
            set {
                withMutation(keyPath: \.\#(pattern)) {
                    UserDefaults.\#(pattern) = newValue
                }
            }
            """#
            ]
        }
        
        // Ensure the macro has one and only one argument.
        guard let exprList = arguments.as(LabeledExprListSyntax.self), exprList.count == 1, let expr = exprList.first?.expression.as(FunctionCallExprSyntax.self) else {
            throw ObservableUserDefaultArgumentError.macroShouldOnlyContainOneArgument
        }
        
        func keyExpr() -> ExprSyntax? {
            expr.arguments.first(where: { $0.label?.text == "key" })?.expression
        }
        
        func defaultValueExpr() -> ExprSyntax? {
            expr.arguments.first(where: { $0.label?.text == "defaultValue" })?.expression
        }
        
        func storeExprDeclName() -> DeclReferenceExprSyntax? {
            expr.arguments.first(where: { $0.label?.text == "store" })?.expression.as(MemberAccessExprSyntax.self)?.declName
        }
        
        if let type = binding.typeAnnotation?.type.as(OptionalTypeSyntax.self), let keyExpr = keyExpr(), let storeName = storeExprDeclName() {
            
            guard defaultValueExpr() == nil else {
                throw ObservableUserDefaultArgumentError.optionalTypeShouldHaveNoDefaultValue
            }
            
            // Macro is attached to an optional type with an argument that contains no default value.
            return [
            #"""
            get {
                access(keyPath: \.\#(pattern))
                return UserDefaults.\#(storeName).value(forKey: \#(keyExpr)) as? \#(type.wrappedType)
            }
            """#,
            #"""
            set {
                withMutation(keyPath: \.\#(pattern)) {
                    UserDefaults.\#(storeName).set(newValue, forKey: \#(keyExpr))
                }
            }
            """#
            ]
            
        } else if let type = binding.typeAnnotation?.type, let keyExpr = keyExpr(), let storeName = storeExprDeclName() {
            
            guard let defaultValueExpr = defaultValueExpr() else {
                throw ObservableUserDefaultArgumentError.nonOptionalTypeMustHaveDefaultValue
            }
            
            // Macro is attached to a non-optional type with an argument that contains a default value.
            return [
            #"""
            get {
                access(keyPath: \.\#(pattern))
                return UserDefaults.\#(storeName).value(forKey: \#(keyExpr)) as? \#(type) ?? \#(defaultValueExpr)
            }
            """#,
            #"""
            set {
                withMutation(keyPath: \.\#(pattern)) {
                    UserDefaults.\#(storeName).set(newValue, forKey: \#(keyExpr))
                }
            }
            """#
            ]
            
        } else {
            throw ObservableUserDefaultArgumentError.unableToExtractRequiredValuesFromArgument
        }
    }
    
}

enum ObservableUserDefaultError: Error, CustomStringConvertible {
    case notVariableProperty
    case propertyMustContainOnlyOneBinding
    case propertyMustHaveNoAccessorBlock
    case propertyMustHaveNoInitializer
    case propertyMustUseSimplePatternSyntax
    
    var description: String {
        switch self {
        case .notVariableProperty:
            return "'@ObservableUserDefault' can only be applied to variables"
        case .propertyMustContainOnlyOneBinding:
            return "'@ObservableUserDefault' cannot be applied to multiple variable bindings"
        case .propertyMustHaveNoAccessorBlock:
            return "'@ObservableUserDefault' cannot be applied to computed properties"
        case .propertyMustHaveNoInitializer:
            return "'@ObservableUserDefault' cannot be applied to stored properties"
        case .propertyMustUseSimplePatternSyntax:
            return "'@ObservableUserDefault' can only be applied to a variables using simple declaration syntax, for example, 'var name: String'"
        }
    }
}

enum ObservableUserDefaultArgumentError: Error, CustomStringConvertible {
    case macroShouldOnlyContainOneArgument
    case nonOptionalTypeMustHaveDefaultValue
    case optionalTypeShouldHaveNoDefaultValue
    case unableToExtractRequiredValuesFromArgument
    
    var description: String {
        switch self {
        case .macroShouldOnlyContainOneArgument:
            return "Must provide an argument when using '@ObservableUserDefault' with parentheses"
        case .nonOptionalTypeMustHaveDefaultValue:
            return "'@ObservableUserDefault' arguments on non-optional types must provide default values"
        case .optionalTypeShouldHaveNoDefaultValue:
            return "'@ObservableUserDefault' arguments on optional types should not use default values"
        case .unableToExtractRequiredValuesFromArgument:
            return "'@ObservableUserDefault' unable to extract the required values from the argument"
        }
    }
}

@main
struct ObservableUserDefaultPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObservableUserDefaultMacro.self
    ]
}

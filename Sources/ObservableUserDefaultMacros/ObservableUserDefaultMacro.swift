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
        
        // Ensure there is no initial value assigned to the variable.
        guard binding.initializer == nil else {
            throw ObservableUserDefaultError.propertyMustHaveNoInitializer
        }
        
        // For simple variable declarations, the binding pattern is `IdentifierPatternSyntax`,
        // which defines the name of a single variable.
        guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            throw ObservableUserDefaultError.propertyMustUseSimplePatternSyntax
        }
        
        // Check if there is an explicit argument provided to the macro.
        // If so, extract the key, defaultValue, and store to use, and provide stored properties from `UserDefaults` that use the values extracted from the macro argument.
        // If not, use a static property on `UserDefaults` with the same name as the property.
        guard let arguments = node.arguments else {
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
        
        // Ensure the macro has one and only one argument.
        guard let exprList = arguments.as(LabeledExprListSyntax.self), exprList.count == 1,
              let expr = exprList.first?.expression.as(FunctionCallExprSyntax.self)
        else {
            throw ObservableUserDefaultArgumentError.macroShouldOnlyContainOneArgument
        }
        
        // Extract the property type and `UserDefaults` key, defaultValue, and store expressions from the argument.
        guard let type = binding.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.name,
              let keyExpr = expr.arguments.first(where: { $0.label?.text == "key" })?.as(LabeledExprSyntax.self),
              let defaultValueExpr = expr.arguments.first(where: { $0.label?.text == "defaultValue" })?.as(LabeledExprSyntax.self),
              let storeExpr = expr.arguments.first(where: { $0.label?.text == "store" })?.as(LabeledExprSyntax.self),
              let storeDeclName = storeExpr.expression.as(MemberAccessExprSyntax.self)?.declName
        else {
            throw ObservableUserDefaultArgumentError.unableToExtractRequiredValuesFromArgument
        }
        
        return [
        #"""
        get {
            access(keyPath: \.\#(pattern.identifier))
            return UserDefaults.\#(storeDeclName).value(forKey: \#(keyExpr.expression)) as? \#(type) ?? \#(defaultValueExpr.expression)
        }
        """#,
        #"""
        set {
            withMutation(keyPath: \.\#(pattern.identifier)) {
                UserDefaults.\#(storeDeclName).set(newValue, forKey: \#(keyExpr.expression))
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
    case unableToExtractRequiredValuesFromArgument
    
    var description: String {
        switch self {
        case .macroShouldOnlyContainOneArgument:
            return "'@ObservableUserDefault' should only contain one argument"
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

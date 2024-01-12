import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros


public struct AddAsyncMethodB: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        let result = try! FunctionDeclSyntax(
        """
        @AddSyncVariant
        func methodB() async -> Void {
            print("hello world")
        }
        """
        
        )
        return [DeclSyntax(result)]

    }
}

/// Implementation of the `AddSyncVariant` macro, which takes a throwing async method and produces a new synchronous, non-throwing variant of the method.
public struct AddSyncVariantMacro: PeerMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
        
        let taskPriority = ExprSyntax.init(stringLiteral: "userInitiated")
        // update function signature: remove async throws
        let functionDecl = declaration.as(FunctionDeclSyntax.self)!
        var methodName = functionDecl.name.description

        
        methodName.removeFirst(1)
        let updatedName = TokenSyntax(stringLiteral: methodName)
        
    
        var updatedFunctionSignature = functionDecl.signature
        updatedFunctionSignature.effectSpecifiers = nil
        
        let firstLine = functionDecl
//            .with(\.name, updatedName)
            .with(\.signature, updatedFunctionSignature)
            .with(\.body, nil)
            .with(\.attributes, .init(stringLiteral: ""))
            
        
        
        // create call to function (to be wrapped in Task)
//        var functionCall = FunctionCallExprSyntax.in
        let nameOnly = functionDecl.name // only name, not keywords like 'static' and 'func'
        let calledExpresion = DeclReferenceExprSyntax(baseName: nameOnly)

        var labeledExpressionList: LabeledExprListSyntax = .init()
        let parameters = functionDecl.signature.parameterClause.parameters
        for parameter in parameters {
            let label = parameter.firstName
            var expression: ExprSyntax = .init(stringLiteral: "expression")
            if let secondName = parameter.secondName {
                expression = .init(stringLiteral: secondName.text)
            } else {
                expression = .init(stringLiteral: parameter.firstName.text)
            }
            
            let labeledExpression = LabeledExprSyntax(label: label.trimmed, colon: .colonToken(), expression: expression, trailingComma: parameter == parameters.last ? nil : .commaToken())
            labeledExpressionList.append(labeledExpression)
        }
        
        let result = try! FunctionDeclSyntax(
            """
            \(firstLine) {
            Task(priority: .\(taskPriority)) {
                
                try await \(calledExpresion)(\(labeledExpressionList))
            
            }
            }
            """
        
        )
        return [DeclSyntax(result)]
        
    }

}

@main
struct nestedMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AddSyncVariantMacro.self,
        AddAsyncMethodB.self
    ]
}

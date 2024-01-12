import nestedMacro
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

class SomeClass {
    
    @AddSyncVariant // ✅ expands as expected, overloading the method below with a sync variant
    func methodA() async throws -> Void {
        print("fn1")
    }
    
    @AddAsyncMethodB // (1) ✅ expands as expected, adding an async method to the class; (2) ❌ resulting nested macro does not seem to expand.
    var someProperty: [String] = .init()
}

let someInstance = SomeClass()

someInstance.methodA() // ✅ Can call this without wrapping method call inside a Task, because @AddSyncVariant succesfully overloads the method with a sync variant.

Task {
    await someInstance.methodB() // ✅ Can call this method because @AddAsyncMethodB successfully adds the new method to the class.
}

someInstance.methodB() // ❌ error: "'async' call in a function that does not support concurrency"

// - Would expect the method call above to be valid, because the @AddAsyncMethodB should expand into a new `methodB' with an @AddSyncVariant macro on top of it, which should overload that method with a sync variant. That last part does not seem to happen.
// - Note that autocomplete in Xcode also recognizes and suggests the sync variant `someInstance.methodB()`


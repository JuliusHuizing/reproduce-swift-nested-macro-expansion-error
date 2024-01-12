// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(peer, names: named(methodB))
public macro AddAsyncMethodB() = #externalMacro(module: "nestedMacroMacros", type: "AddAsyncMethodB")

/// A macro that overloads the target method with an non-throwing, async variant.
@attached(peer, names: overloaded)
public macro AddSyncVariant() = #externalMacro(module: "nestedMacroMacros", type: "AddSyncVariantMacro")

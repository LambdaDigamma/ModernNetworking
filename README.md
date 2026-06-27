# ModernNetworking

ModernNetworking is a SwiftPM package for composing HTTP request loaders,
request/response models, and body encoders.

## Concurrency

The package targets Swift 6.2 concurrency settings and enables
`NonisolatedNonsendingByDefault` and `InferIsolatedConformances`.
It intentionally does not enable default `MainActor` isolation so networking
and model APIs remain actor-agnostic for library consumers.

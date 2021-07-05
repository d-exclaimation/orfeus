# MutationAgent

MutationAgent will manage returned data from a GraphQL Mutation

GraphQL Mutation Observable to manage Mutation State

## Usage

### Instansiate agent
```swift
@StateObject
var someMutation = MutationAgent(
    mutation: SomeGraphQLMutation.Type,
)
// or use the "hook"
@StateObject
var someMutation = Orfeus.agent(
    mutation: SomeGraphQLMutation.Type,
)

var body: some View {
    Button {
        guard case .idle = someMutation.state else { return }
        someMutation.mutate(
            variables: SomeGraphQLMutation(...params)
        )
    } label: {
        Text("Mutate!")
    }
}
```

## Side Effects

When performing a mutation, you might want to apply some side effects afterwards, This can be done directly in calling `mutate` method

### Handling invalidate of data from QueryAgent or clearing Apollo Cache
```swift
someMutation.mutate(
    variables: SomeGraphQLMutation,
    onCompleted: { _ in
        Orfeus.shared.apollo.clearCache()
        someQuery.invalidate()
        // QueryAgent is OrfeusInvalidatableAgent, thus you can group them together
        let queryAgents: [OrfeusInvalidatableAgent] = [...]
        queryAgents.forEach { $0.invalidate() }
    },
    onError: { err in ... }
)
```

Orfeus have a wrapping enum for Error instead of raw Error or GraphQL. This is for being able to respond to any type failure. Learn more [`Orfeus.Fault`](./Fault.md)
### Handling errors
```swift
someMutation.mutate(
    variables: SomeGraphQLMutation,
    onCompleted: { data in ... },
    onError: { err in
        switch err {
        case .requestFailed(let reason):
            show(reason)
        case .graphqlErrors(errors: let errors):
            errors.map { $0.message }.forEach { show($0) }
        case .nothingHappened:
            show("Please wait while issues are being resolve!")
    }
)
```

Data managed by MutationAgent is identical to [`QueryAgent`](./Queries.md)


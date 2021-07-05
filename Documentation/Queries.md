# QueryAgent
GraphQL Query Observable to manage Query State

QueryAgent will manage state of incoming request out of the box

## Usage: Initialize

### Orfeus agent "hook"
```swift
@StateObject
var someQuery = Orfeus.agent(
    query: SomeGraphQLQuery()
)
```

### Initialize and load
```swift
@StateObject
var someQuery = QueryAgent(SomeGraphQLQuery()).load()
```

### Initialize not load
```swift
@StateObject
var someQuery = QueryAgent(
    query: SomeGraphQLQuery(),
    fallback: nil
)
// Data is not loaded
```

Highly recommend taking advatage of `state` property as it allow for type safe, clear declarative workflow

## Usage: State

Learn more about state in [`AgentState`](./AgentState.md)

### State with Switch on view builder
State of the Query for better clarify over current situtation of data

 ```swift
 switch roomAgent.state {
 case .idle:
     EmptyView("Not loaded")
 case .loading:
     Text("Loading...")
 case .succeed(let data):
     LazyVStack {
         ForEach(data.posts, content: Post.init(post:))
     }
 }
 case .failed(_):
     Text("No data")
 }
 ```

 ### State with OrfeusSuspense
 ```swift
 struct ContentView: View {
     @StateObject
     var someQuery = QueryAgent(...).load()
     var body: some View {
         OrfeusSuspense(state: state) { data in
             SomeView(data: data)
         }
     }
 }
 ```
 more examples on [`AgentState`](./AgentState.md)

 ## APIs

 #### Load query agent

 ```swift
 QueryAgent(...).load()
 ```

 **Description**: Send Query request and return agent

  #### Invalidate query agent

 ```swift
 QueryAgent(...).invalidate()
 ```
 **Description**: Resend Query request and overwrite state

 QueryAgent conforms to the protocol [`OrfeusInvalidatableAgent`](./../Orfeus/Agent.swift) which require a invalidate method. 

# AwaitingAgent
GraphQL Query Observable to manage Query State but watch for cache value changes 

## Benefit
> - Reflect cache request immeditelly
> - Automatic invalidation

## Downside
> - Out of your control
> - Managed properly can cause memory leak
> - Need to use cache, thus data can be stale

## Usage: Initialize

### Orfeus agent "hook"
```swift
@StateObject
var someQuery = Orfeus.agent(
    awaiting: SomeGraphQLQuery()
)
```

### Initialize and load
```swift
@StateObject
var someQuery = AwaitingAgent(SomeGraphQLQuery()).watch()
```

### Initialize not load
```swift
@StateObject
var someQuery = AwaitingAgent(
    query: SomeGraphQLQuery(),
    fallback: nil
)
// Data is not watched
```

Most of the APIs is identical to [`QueryAgent`](#queryagent)

## Getting values from other state

It's common to use other properties to fetch the correct data. You can do this by initializing all properties from the init function of your SwiftUI View.

```swift
init(id: id) {
    self.id = id
    _someQuery = StateObject(wrappedValue: Orfeus.agent(
        query: SomeGraphQLQuery(id: id),
        fallback: nil
    ))
}
```

There is shorthand for this so it's a lot nicer with less boilerplate-ish

```swift
init(id: id) {
    self.id = id
    _someQuery = Orfeus.wrapped(
        query: SomeGraphQLQuery(id: id),
        fallback: nil
    )
}
```
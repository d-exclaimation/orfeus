# QueryAgent
GraphQL Query Observable to manage Query State

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

 ### State with custom Suspensing View
 ```swift
 struct ContentView: View {
     @StateObject
     var someQuery = QueryAgent(...).load()
     var body: some View {
         view(state: someQuery.state)
     }
 }

 extension ContentView: SuspensingView {
     var loadingView: some View {
         Text("...loading")
     }

     func successView(for data: SomeQuery.Data) -> some View {
         Text("\(data.some)")
     }

     func faultView(for fault: Orfeus.Fault) -> some View {
         Text("\(fault.message)")
     }
 }
 ```
 
 ### State with React-Query style
 ```swift
 struct ContentView: View {
     @StateObject
     var someQuery = QueryAgent(...).load()
     @ViewBuilder var body: some View {
         if someQuery.isLoading {
             Text("...loading")
         } else {
             SomeView(data: someQuery.data ?? SomethingElse()) 
         }
     }
 }
 ```

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

Highly recommend taking advatage of `state` property as it allow for type safe, clear declarative workflow

## Usage: State

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
     var someQuery = AwaitingAgent(...).watch()
     var body: some View {
         OrfeusSuspense(state: state) { data in
             SomeView(data: data)
         }
     }
 }
 ```

 ### State with custom Suspensing View
 ```swift
 struct ContentView: View {
     @StateObject
     var someQuery = AwaitingAgent(...).watch()
     var body: some View {
         view(state: someQuery.state)
     }
 }

 extension ContentView: SuspensingView {
     var loadingView: some View {
         Text("...loading")
     }

     func successView(for data: SomeQuery.Data) -> some View {
         Text("\(data.some)")
     }

     func faultView(for fault: Orfeus.Fault) -> some View {
         Text("\(fault.message)")
     }
 }
 ```
 
 ### State with React-Query style
 ```swift
 struct ContentView: View {
     @StateObject
     var someQuery = AwaitingAgent(...).watch()
     @ViewBuilder var body: some View {
         if someQuery.isLoading {
             Text("...loading")
         } else {
             SomeView(data: someQuery.data ?? SomethingElse()) 
         }
     }
 }
 ```

 ## APIs

 #### Load query agent

 ```swift
 QueryAgent(...).watch()
 ```

 **Description**: Watch Query request cache and return agent

  #### Invalidate query agent

 ```swift
 QueryAgent(...).invalidate()
 ```
 **Description**: Re-initialze watch Query request and overwrite state

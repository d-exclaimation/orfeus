# AgentState

AgentState represent current data and process of the request.

In Apollo Client React for example, data information is split into `loading`, `data`, and `error`. This is fine approach but the type system won't be able to infer that if `error` is `nil`, data must not be `nil`.

Therefore, Orfeus uses custom enum to present current state of the process [(Insipired by Pigeon, a React-Query for Swift)](https://github.com/fmo91/Pigeon). Think of a simple state machine. This way if request succeed data will be guaranteed to be not nil, and vice versa


## States

### Idle
```swift
AgentState<SomeQuery>.idle
```
**Description**: Represent no request was made, yet agent is instansiated

### Loading
```swift
AgentState<SomeQuery>.loading
```
**Description**: Represent request was made, yet response have not arrived

### Succeed
```swift
AgentState<SomeQuery>.succeed(SomeQuery.Data)
```
**Description**: Request was made and data successfully returned

| Values | Type | Description |
|--------|------|-------------|
| *data* | `GraphQLOperation.Data` | Data from a successful GraphQLOperation|

### Succeed
```swift
AgentState<SomeQuery>.failure(Orfeus.Fault)
```
**Description**: Request was made but an error occurred

| Values | Type | Description |
|--------|------|-------------|
| *error* | `Orfeus.Fault` | Type of possible error from request |

Learn more on [`Orfeus.Fault`](./Fault.md)


## Usage

### Switch statement with ViewBuilder
```swift
switch roomAgent.state {
case .idle, .loading:
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

### With OrfeusSuspense
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
[`Link`](./../Orfeus/Views/OrfeusSuspense.swift)

### With custom Suspensing View
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
[`Link`](./../Orfeus/Views/SuspensingView.swift)

## Using React-style data management

Now, if you feel like using the explicit split between `loading`, `data`, and `error`. AgentState provide a computed properties for that,

```swift
let state: AgentState<String>.succeed("Ok")

state.data // > Optional<String>("Ok")

state.isLoading // > False

state.error // > Optional<Orfeus.Fault>.none
```

## Equatable protocol

AgentState conforms to equatable when values wrapped in also `Equatable`, allow you to use SwiftUI's native `onChange` View lifecycle handler.

```swift
@State
var state = AgentState<String>.idle

var body: some View {
	VStack {
		...
	}
	.onChange(of: state) { state in
		print(state)
	}
}
```
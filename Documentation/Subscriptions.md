# SnapshotAgent
GraphQL Agent for managing Subscription based on snapshot of data and callbacks

The idea of snapshot agent is to only manage state per snapshot basis meaning that it will replicate incoming data, but give most control to you in form of a callback
option to handle the rest yourself. This approach is similar to the MutationAgent. 

If you are looking for an agent to manage the data automatically with more control on the agent itself, you might be looking for [`StreamAgent`](#streamagent)

## Usage: Initialize

### Orfeus agent "hook"
```swift
@StateObject
var snapshotSubscription = Orfeus.agent(
    snapshot: SomeGraphQLSubscription.self
)

var body: some View {
    VStack {
        ...
    }
    .onAppear {
        snapshotSubscription.subscribe(
            subscription: SomeGraphQLSubscription(variables: ...),
            onReceive: handleReceive(res:)
        )
    }
}

func handleReceive(res: Result<SomeGraphQLSubscription.Data, Orfeus.Fault>) -> Void {
    switch res {
    case .succeed(let data):
        ...
    case .failure(let fault):
        ...
    }
}
```

By default this will not watch nor subscribe until specifically `subscribe` method called

## Side Effects

When performing a subscription, you might want to apply some side effects after each request coming in, This can be done directly in calling `subscribe` method. The difference from MutationAgent is that the data is not split into error and result, but combined together. In addition, the receiver should also return a value to update the snapshot.

### Handling receive value with callbacks
```swift
someMutation.mutate(
    subscription: SomeGraphQLMutation,
    onReceive: { res in
        if case let .succeed(data) = res {
            return .update(data)
        }
        return .halt // stop process
    }
)
```

### Returned value to update snapshot
```swift
enum ReturnedSnapshot {
   case halt // -> Stop subscription
   case .update(Snapshot) // -> Update snapshot to the data given
   case .fault(Fault) // -> Update snapshot to an .error state
}
```

**NOTE:** This agent does perform cancel on deinit automatically, you can stop subscription by calling `cancel` or returning .halt to the receiver callback

Data managed by SnapshotAgent is identical to [`QueryAgent`](./Queries.md)

# StreamAgent

GraphQL Agent for managing subscription based on reducer function and streams

The difference from this to the SnapshotAgent is that data is managed all by the agent, avoiding callbacks a much as possible. You provide a reducer function to reduce the current state with the incoming data to produce a new value, thus more customization.

## Benefit
> - Reducer function provide declarative pure functional way of handling incoming data
> - Less callbacks to worry about
> - Allow for initial data received
> - Cleaner API for state management

## Downside
> - Subscription variables must be given on initialization, thus may require you to handle this in `init`
> - Perform side effects is trickier
> - Reducer function must be pure on initialization

## Usage: Initialize

### Orfeus agent "hook"
```swift
// Reduced to an array
@StateObject
var snapshotSubscription = Orfeus.agent(
    stream: SomeGraphQLSubscription(variables: ...),
    initial: [SomeGraphQLSubscription.Data](),
    reducer: { acc, curr in acc + [curr] }
)
```

## Side Effects

Side effects can be tricky to do here, but it's possible. The only downside is that it will not allow for intercepting data to state, only the reducer is responsible for state management

### Adding a side effect callback using onDataChange

Orfeus provide a simple lifecycle event handler called onDataChange that run after the reducer

```swift
.onDataChange(agent: agent) { data in
    // .. do something
}
```

If you want to append multiple side effects, you can use the `sink` method (simulating the publisher decorators)

```swift
agent.sink(listener: /* ... */)

[].forEach { agent.sink(listener: $0) }
```

There is experimental API for onChange to use Agent without having the data to be equatable which is not by default for Apollo Client's Code generated Data. However, it's best to make your data equatable instead and use the native onChange lifecycle event handler. Check [`AgentState`](./AgentState.md) for more info

### onChange
```swift
onChange(of: agent.state) { state in
    // .. do something
}
```

Data managed by StreamAgent is somewhat identical to [`QueryAgent`](./Queries.md)

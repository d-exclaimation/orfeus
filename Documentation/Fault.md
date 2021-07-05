# Fault

Apollo Client provides their own abstraction for Error called GraphQL, but they use Swift's native `Result` type for passing in that information. These errors are only available once Result passed from their callback is a success, then you can see the GraphQL Errors. This creates an issue where you have to do error handling twice and nested.

Orfeus tries to provide a simpler experience and flatten the errors into one error using a custom enum called `Fault`

## Faults

### Request failed
```swift
Orfeus.Fault.requestFailed(reason: String)
```
**Description**: Represent that request failed on network level

| Values | Type | Description |
|--------|------|-------------|
| *reason* | `String` | Error message thrown |

### GraphQL Request error
```swift
Orfeus.Fault.graphqlErrors(errors: [GraphQLError])
```
**Description**: Represent error where thrown from GraphQL Server

| Values | Type | Description |
|--------|------|-------------|
| *errors* | `Array<GraphQLError>` | All the error message from GraphQL Server |

### Succeed
```swift
Orfeus.Fault.nothingHappened
```
**Description**: Request was made, no graphql errors, yet no data

**Possible reasoning**:
1. Server response in 204 no content, yet Apollo doesn't pick it up
2. Data failed to be parse midway
3. GraphQL Error Occured, yet given no description
4. Network issues but not picked up

## Properties

To make things even simpler, there are two extra computed properties to flatten / cast things further.

```swift
let fault = Orfeus.fault.requestFailed(reason: "I don't know")

fault.message // "I don't know"

fault.errors // Array<GraphQLError>[GraphQLError(message: "I don't know")]
```
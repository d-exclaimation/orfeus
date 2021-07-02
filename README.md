# Orfeus

Wrapping Library for Apollo Client iOS to manage state and actions in SwiftUI

## Usage

Haven't made this to work as package at all

### Manual
1. Clone / Copy all the files in a directory in your project
2. Update the Apollo Client instansiation values to match your requirement i.e. SplitNetwork or regular URL
```swift
public class Orfeus {
    /// Shared singleton instance of Orfeus
    public static let shared = Orfeus()
    
    /// Apollo client wrapper
    public lazy var apollo = ApolloClient(url: URL(string: "your url here")!) // i.e SplitNetwork
```
2.1. or Re-assign the static shared properties
```swift
Orfeus.shared = ApolloClient(url: URL(string: "your url here")!)
```
3. Use the Agents to manage state
```swift
struct ContentView: View {
    @StateObject
    var someQuery = Orfeus.use(
        query: SomeQuery()
    )

    var body: some View {
        Group {
            if someQuery.isLoading {
                Text("loading...")
            }
            Text("\(someQuery.data)")
        }
    }
}
```

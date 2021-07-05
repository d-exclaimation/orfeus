//
//  OrfeusOnChange.swift
//  MessageRacer
//
//  Created by Vincent on 7/4/21.
//

import SwiftUI
import Apollo

struct OrfeusOnChange<TSubscription: GraphQLSubscription, StreamPayload>: ViewModifier {
    @ObservedObject
    var agent: Orfeus.StreamAgent<TSubscription, StreamPayload>
    
    let listener: (StreamPayload) -> Void
    
    public func body(content: Content) -> some View {
        content
            .onAppear {
                agent.register(listener: listener)
            }
    }
}

extension View {
    /// handle incoming data from stream in case onChange does not cut it 
    public func onChange<TSubscription: GraphQLSubscription, StreamPayload>(
        agent: Orfeus.StreamAgent<TSubscription, StreamPayload>,
        perform listener: @escaping (StreamPayload) -> Void
    ) -> some View {
        modifier(OrfeusOnChange<TSubscription, StreamPayload>(agent: agent, listener: listener))
    }
}

//
//  FetchChart.swift
//  
//
//  Created by Gustavo Ordaz on 11/17/19.
//

@testable import StateMachine

enum FetchStates {
    case idle
    case loading
    case success
    case cancelled
    case failure
}

enum FetchActions {
    case fetch
    case resolve
    case reject
    case retry
}

let fetchChart = Chart(
    id: "fetch",
    initial: FetchStates.idle,
    context: ["count": 0],
    states: [
        .idle: [
            .on([FetchActions.fetch: .simple(.loading)])
        ],
        .loading: [
            .on([
                .resolve: .simple(.success),
                .reject: .simple(.failure),
            ])
        ],
        .success: nil,
        .cancelled: [
            .type("final")
        ],
        .failure: [
            .on([
                .retry: .withContext(
                    target: .loading,
                    action: { ctx in
                        var context = ctx
                        context["count"] = context["count"] as! Int + 1
                        return context
                }),
                .reject: .simple(.cancelled)
            ])
        ],
    ]
)

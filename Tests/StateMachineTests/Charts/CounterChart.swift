//
//  CounterChart.swift
//  
//
//  Created by Gustavo Ordaz on 11/17/19.
//

@testable import StateMachine

enum CounterStates {
    case active
}

enum CounterActions {
    case increment
    case decrement
}

typealias CounterContext = (Int)

typealias CounterChart = Chart<CounterStates, CounterActions, CounterContext>

let counterChart: CounterChart = Chart(
    id: "counter",
    initial: .active,
    context: (0),
    states: [
        .active: [
            .on([
                .increment: .withActions(
                    target: .active,
                    actions: ["increment"]
                ),
                .decrement: .withActions(
                    target: .active,
                    actions: ["decrement"]
                )
            ])
        ]
    ],
    actions: [
        "increment": { (count) in (count + 1) },
        "decrement": { (count) in (count - 1) }
    ]
)

let guardedCounter: CounterChart = Chart(
    id: "counter",
    initial: .active,
    context: (0),
    states: [
        .active: [
            .on([
                .increment: .withActions(
                    target: .active,
                    actions: ["increment"]
                ),
                .decrement: .withActionsAndGuards(
                    target: .active,
                    actions: ["decrement"],
                    cond: "notNegative"
                )
            ])
        ]
    ],
    actions: [
        "increment": { (count) in (count + 1) },
        "decrement": { (count) in (count - 1) }
    ],
    guards: [
        "notNegative": { (count) in count >= 0 },
    ]
)

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

typealias CounterChart = Chart<CounterStates, CounterActions>

let counterChart: CounterChart = Chart(
    id: "counter",
    initial: .active,
    context: ["count": 0],
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
        "increment": { ctx in
            var context = ctx
            context["count"] = context["count"] as! Int + 1
            return context
        },
        "decrement": { ctx in
            var context = ctx
            context["count"] = context["count"] as! Int - 1
            return context
        }
    ]
)

let guardedCounter: CounterChart = Chart(
    id: "counter",
    initial: .active,
    context: ["count": 0],
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
        "increment": { ctx in
            var context = ctx
            context["count"] = context["count"] as! Int + 1
            return context
        },
        "decrement": { ctx in
            var context = ctx
            context["count"] = context["count"] as! Int - 1
            return context
        }
    ],
    guards: [
        "notNegative": { ctx in
            ctx["count"] as! Int >= 0
        },
    ]
)

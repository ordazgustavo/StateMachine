//
//  LightStates.swift
//  
//
//  Created by Gustavo Ordaz on 11/17/19.
//

@testable import StateMachine

enum LightStates {
    case green
    case yellow
    case red
}

enum LightActions {
    case timer
}

let simpleLightChart = Chart(
    id: "lights",
    initial: LightStates.green,
    context: nil,
    states: [
        .green: [.on([LightActions.timer: .simple(.yellow)])],
        .yellow: [.on([.timer: .simple(.red)])],
        .red: [.on([.timer: .simple(.green)])],
    ]
)

let lightChart = Chart(
    id: "lights",
    initial: LightStates.green,
    context: ["color": "green"],
    states: [
        .green: [
            .on([
                LightActions.timer: .withContext(
                    target: .yellow,
                    action: { _ in return ["color": "yellow"] }
                )
            ])
        ],
        .yellow: [
            .on([
                .timer: .withContext(
                    target: .red,
                    action: { _ in return ["color": "red"] }
                )
            ])
        ],
        .red: [
            .on([
                .timer: .withContext(
                    target: .green,
                    action: { _ in return ["color": "green"] }
                )
            ])
        ],
    ]
)

import XCTest
@testable import StateMachine

final class StateMachineTests: XCTestCase {
    enum States {
        case yellow
        case red
        case green
    }
    
    enum Actions {
        case timer
    }
    
    func testMachineWorks() {
        var machine = Machine<States, Actions>(
            initial: .green,
            context: nil,
            states: [
                .green: [.on([.timer: .simple(.yellow)])],
                .yellow: [.on([.timer: .simple(.red)])],
                .red: [.on([.timer: .simple(.green)])],
            ]
        )
        
        let result = machine.transition(state: machine.initial, event: .timer)
        
        XCTAssertEqual(result, .yellow)
        XCTAssertNotEqual(result, .red)
    }
    
    func testMachineSetsContext() {
        var machine = Machine<States, Actions>(
            initial: .green,
            context: nil,
            states: [
                .green: [
                    .on([
                        .timer: .withContext((
                            target: .yellow,
                            action: { _ in ["color": "yellow"]}
                        ))
                    ])
                ],
                .yellow: [
                    .on([
                        .timer: .withContext((
                            target: .red,
                            action: { _ in ["color": "red"]}
                        ))
                    ])
                ],
                .red: [
                    .on([
                        .timer: .withContext((
                            target: .green,
                            action: { _ in ["color": "green"]}
                        ))
                    ])
                ],
            ]
        )
        
        XCTAssertNil(machine.context)
        
        let result = machine.transition(state: machine.initial, event: .timer)
        
        XCTAssertEqual(result, .yellow)
        
        XCTAssertNotNil(machine.context)
        
        guard let ctx = machine.context as? [String: String] else {
            XCTFail("Failed to assert context.")
            return
        }
        XCTAssert(ctx["color"] == "yellow")
    }
    
    func testMachineInstatiationByChartConstant() {
        let chart: Chart<States, Actions> = (
            initial: .green,
            context: nil,
            states: [
                .green: [.on([.timer: .simple(.yellow)])],
                .yellow: [.on([.timer: .simple(.red)])],
                .red: [.on([.timer: .simple(.green)])],
            ],
            actions: nil,
            guards: nil
        )
        
        var machine = Machine(forChart: chart)
        
        let result = machine.transition(state: machine.initial, event: .timer)
        
        XCTAssertEqual(result, .yellow)
        XCTAssertNotEqual(result, .red)
    }
    
    func testMachineFinishState() {
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
        let fetchChart: Chart<FetchStates, FetchActions> = (
            initial: .idle,
            context: 0,
            states: [
                .idle: [
                    .on([.fetch: .simple(.loading)])
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
                        .retry: .withContext((
                            target: .loading,
                            action: { $0 as! Int + 1 }
                        )),
                        .reject: .simple(.cancelled)
                    ])
                ],
            ],
            actions: nil,
            guards: nil
        )
        
        var machine = Machine(forChart: fetchChart)
        
        XCTAssertEqual(machine.context as! Int, 0)
        
        let result = machine.transition(state: .idle, event: .fetch)
        XCTAssertEqual(result, .loading)
        
        let result2 = machine.transition(state: result, event: .reject)
        XCTAssertEqual(result2, .failure)
        
        let result3 = machine.transition(state: result2, event: .retry)
        XCTAssertEqual(result3, .loading)
        XCTAssertEqual(machine.context as! Int, 1)
        
        let result4 = machine.transition(state: result3, event: .reject)
        XCTAssertEqual(result4, .failure)
        
        let result5 = machine.transition(state: result4, event: .retry)
        XCTAssertEqual(result5, .loading)
        XCTAssertEqual(machine.context as! Int, 2)
        
        let result6 = machine.transition(state: result5, event: .resolve)
        XCTAssertEqual(result6, .success)
        
        XCTAssertEqual(machine.currentState, .success)
        
        let result7 = machine.transition(state: result5, event: .resolve)
        XCTAssertEqual(result7, .success)
        XCTAssertEqual(machine.currentState, .success)
    }
    
    func testMachineActions() {
        enum CounterStates {
            case active
        }
        enum CounterActions {
            case increment
            case decrement
        }
        
        let chart: Chart<CounterStates, CounterActions> = (
            initial: .active,
            context: 0,
            states: [
                .active: [
                    .on([
                        .increment: .withActions((
                            target: .active,
                            actions: ["increment"]
                        )),
                        .decrement: .withActions((
                            target: .active,
                            actions: ["decrement"]
                        ))
                    ])
                ]
            ],
            actions: [
                "increment": { $0 as! Int + 1 },
                "decrement": { $0 as! Int - 1 }
            ],
            guards: nil
        )
        
        var machine = Machine(forChart: chart)
        XCTAssertEqual(machine.context as! Int, 0)
        
        _ = machine.transition(state: .active, event: .increment)
        XCTAssertEqual(machine.context as! Int, 1)
        
        _ = machine.transition(state: .active, event: .increment)
        XCTAssertEqual(machine.context as! Int, 2)
        
        _ = machine.transition(state: .active, event: .decrement)
        XCTAssertEqual(machine.context as! Int, 1)
    }
    
    func testMachineGuards() {
        enum CounterStates {
            case active
        }
        enum CounterActions {
            case increment
            case decrement
        }
        
        let chart: Chart<CounterStates, CounterActions> = (
            initial: .active,
            context: 0,
            states: [
                .active: [
                    .on([
                        .increment: .withActions((
                            target: .active,
                            actions: ["increment"]
                        )),
                        .decrement: .withActionsAndGuards((
                            target: .active,
                            actions: ["decrement"],
                            cond: "notNegative"
                        ))
                    ])
                ]
            ],
            actions: [
                "increment": { $0 as! Int + 1 },
                "decrement": { $0 as! Int - 1 }
            ],
            guards: [
                "notNegative": { $0 as! Int >= 0 }
            ]
        )
        
        var machine = Machine(forChart: chart)
        XCTAssertEqual(machine.context as! Int, 0)
        
        _ = machine.transition(state: .active, event: .increment)
        XCTAssertEqual(machine.context as! Int, 1)
        
        _ = machine.transition(state: .active, event: .increment)
        XCTAssertEqual(machine.context as! Int, 2)
        
        _ = machine.transition(state: .active, event: .decrement)
        XCTAssertEqual(machine.context as! Int, 1)
        
        _ = machine.transition(state: .active, event: .decrement)
        XCTAssertEqual(machine.context as! Int, 0)
        
        _ = machine.transition(state: .active, event: .decrement)
        XCTAssertEqual(machine.context as! Int, 0)
        
        _ = machine.transition(state: .active, event: .increment)
        XCTAssertEqual(machine.context as! Int, 1)
    }
    
    static var allTests = [
        ("testMachineWorks", testMachineWorks),
        ("testMachineSetsContext", testMachineSetsContext),
        ("testMachineInstatiationByChartConstant", testMachineInstatiationByChartConstant),
        ("testMachineFinishState", testMachineFinishState),
        ("testMachineActions", testMachineActions),
        ("testMachineGuards", testMachineGuards),
    ]
}

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
                .green: [.on: .simple([.timer: .yellow])],
                .yellow: [.on: .simple([.timer: .red])],
                .red: [.on: .simple([.timer: .green])]
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
                    .on: .withContext(
                        [.timer: (.yellow, { _ in ["color": "yellow"]})]
                    )
                ],
                .yellow: [
                    .on: .withContext(
                        [.timer: (.red, { _ in ["color": "red"]})]
                    )
                ],
                .red: [
                    .on: .withContext(
                        [.timer: (.green, { _ in ["color": "green"]})]
                    )
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
                .green: [.on: .simple([.timer: .yellow])],
                .yellow: [.on: .simple([.timer: .red])],
                .red: [.on: .simple([.timer: .green])]
            ]
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
                    .on: .simple([.fetch: .loading])
                ],
                .loading: [
                    .on: .simple([
                        .resolve: .success,
                        .reject: .failure
                    ])
                ],
                .success: nil,
                .cancelled: nil,
                .failure: [
                    .on: .withContext([
                        .retry: (.loading, { $0 as! Int + 1 }),
                        .reject: (.cancelled, { $0 })
                    ])
                ],
            ]
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

    static var allTests = [
        ("testMachineWorks", testMachineWorks),
        ("testMachineSetsContext", testMachineSetsContext),
        ("testMachineInstatiationByChartConstant", testMachineInstatiationByChartConstant),
        ("testMachineFinishState", testMachineFinishState),
    ]
}

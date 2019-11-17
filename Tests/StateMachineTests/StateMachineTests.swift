import XCTest
@testable import StateMachine

final class StateMachineTests: XCTestCase {
    func testMachineWorks() {
        var machine = Machine(forChart: simpleLightChart)
        
        let result = machine.transition(state: machine.initial, event: .timer)
        
        XCTAssertEqual(result, .yellow)
        XCTAssertNotEqual(result, .red)
    }
    
    func testMachineSetsContext() {
        var machine = Machine(forChart: lightChart)
        
        let result = machine.transition(state: machine.initial, event: .timer)
        
        XCTAssertEqual(result, .yellow)
        
        XCTAssertNotNil(machine.context)
        
        guard let ctx = machine.context as? [String: String] else {
            XCTFail("Failed to typecast context.")
            return
        }
        XCTAssertEqual(ctx["color"], "yellow")
    }
    
    func testMachineFinishState() {
        var machine = Machine(forChart: fetchChart)
        
        XCTAssertEqual(machine.context?["count"] as! Int, 0)
        
        let result = machine.transition(state: .idle, event: .fetch)
        XCTAssertEqual(result, .loading)
        
        let result2 = machine.transition(state: result, event: .reject)
        XCTAssertEqual(result2, .failure)
        
        let result3 = machine.transition(state: result2, event: .retry)
        XCTAssertEqual(result3, .loading)
        XCTAssertEqual(machine.context?["count"] as! Int, 1)
        
        let result4 = machine.transition(state: result3, event: .reject)
        XCTAssertEqual(result4, .failure)
        
        let result5 = machine.transition(state: result4, event: .retry)
        XCTAssertEqual(result5, .loading)
        XCTAssertEqual(machine.context?["count"] as! Int, 2)
        
        let result6 = machine.transition(state: result5, event: .resolve)
        XCTAssertEqual(result6, .success)
        
        XCTAssertEqual(machine.currentState, .success)
        
        let result7 = machine.transition(state: result5, event: .resolve)
        XCTAssertEqual(result7, .success)
        XCTAssertEqual(machine.currentState, .success)
    }
    
    func testMachineActions() {
        var machine = Machine(forChart: counterChart)
        XCTAssertEqual(machine.context?["count"] as! Int, 0)
        
        machine.transition(from: .active, with: .increment)
        XCTAssertEqual(machine.context?["count"] as! Int, 1)
        
        machine.transition(from: .active, with: .increment)
        XCTAssertEqual(machine.context?["count"] as! Int, 2)
        
        machine.transition(from: .active, with: .decrement)
        XCTAssertEqual(machine.context?["count"] as! Int, 1)
    }
    
    func testMachineGuards() {
        var machine = Machine(forChart: guardedCounter)
        XCTAssertEqual(machine.context?["count"] as! Int, 0)
        
        machine.transition(from: .active, with: .increment)
        XCTAssertEqual(machine.context?["count"] as! Int, 1)
        
        machine.transition(from: .active, with: .increment)
        XCTAssertEqual(machine.context?["count"] as! Int, 2)
        
        machine.transition(from: .active, with: .decrement)
        XCTAssertEqual(machine.context?["count"] as! Int, 1)
        
        machine.transition(from: .active, with: .decrement)
        XCTAssertEqual(machine.context?["count"] as! Int, 0)
        
        machine.transition(from: .active, with: .decrement)
        XCTAssertEqual(machine.context?["count"] as! Int, 0)
        
        machine.transition(from: .active, with: .increment)
        XCTAssertEqual(machine.context?["count"] as! Int, 1)
    }
    
    static var allTests = [
        ("testMachineWorks", testMachineWorks),
        ("testMachineSetsContext", testMachineSetsContext),
        ("testMachineFinishState", testMachineFinishState),
        ("testMachineActions", testMachineActions),
        ("testMachineGuards", testMachineGuards),
    ]
}

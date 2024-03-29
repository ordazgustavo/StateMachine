//
//  Machine.swift
//  
//
//  Created by Gustavo Ordaz on 11/9/19.
//

// MARK: Declarations

public struct Machine<State:Hashable, Actions:Hashable, Context> {
    public typealias OurChart = Chart<State, Actions, Context>
    
    public var chart: OurChart
    public let initial: State
    public var context: Context
    public var currentState: State
    private var alive = true
}

// MARK: - init

extension Machine {
    public init(forChart chart: OurChart) {
        self.chart = chart
        self.context = chart.context
        self.initial = chart.initial
        self.currentState = chart.initial
    }
}

// MARK: - Transition

extension Machine {
    public mutating func transition(
        state: State,
        event actionType: Actions) -> State {
        guard alive != false else { return self.currentState }
        
        guard let transitions = getTransitions(from: state) else {
            return self.currentState
        }
        
        for case let .type(type) in transitions where type == "final" {
            self.alive = false
            return self.currentState
        }
        
        for case let .on(event) in transitions {
            guard let target = event[actionType] else {
                return self.currentState
            }
            setState(from: target)
            break
        }
        
        return self.currentState
    }
    
    public mutating func transition(
        from state: State,
        with actionType: Actions) {
        guard alive != false else { return }
        
        guard let transitions = getTransitions(from: state) else { return }
        
        for case let .type(type) in transitions where type == "final" {
            self.alive = false
            return
        }
        
        for case let .on(event) in transitions {
            guard let target = event[actionType] else { return }
            setState(from: target)
            break
        }
    }
}

// MARK: - Helpers

extension Machine {
    private mutating func getTransitions(
        from state: State) -> [OurChart.TransitionTypes]? {
        guard let transitions = self.chart.states[state] else {
            self.alive = false
            return nil
        }
        
        guard let availableTransitions = transitions else {
            self.alive = false
            return nil
        }
        
        return availableTransitions
    }
    
    private mutating func setState(from target: OurChart.VariadicState) {
        switch target {
        case .simple(let simple):
            self.currentState = simple
            break
            
        case .withContext(let (tgt, action)):
            handleWithContextEvent(action: action)
            self.currentState = tgt
            break
            
        case .withActions(let (tgt, actions)):
            handleWithActionsEvent(actions: actions)
            self.currentState = tgt
            break
            
        case .withGuards(let (tgt, cond)):
            let shouldUpdate = handleWithGuardsEvent(
                context: self.context,
                cond: cond
            )
            
            if shouldUpdate {
                self.currentState = tgt
            }
            break
            
        case .withActionsAndGuards(let (tgt, actions, cond)):
            let shouldUpdate = handleWithActionsAndGuardsEvent(
                actions: actions,
                cond: cond
            )
            
            if shouldUpdate {
                self.currentState = tgt
            }
            break
        }
    }
    
    private mutating func handleWithContextEvent(
        action: OurChart.ActionHandler) {
        self.context = action(self.context)
    }
    
    private mutating func handleWithActionsEvent(actions: [String]) {
        guard let ourActions = self.chart.actions else { return }
        
        for action in actions {
            guard let act = ourActions[action] else { continue }
            self.context = act(self.context)
        }
    }
    
    private func handleWithGuardsEvent(
        context: Context,
        cond: String) -> Bool {
        /// Allow to update the given state if the user:
        /// 1. Needs guards but did not provide a guards array
        guard let ourGuards = self.chart.guards else { return true }
        /// 2. Provided guards but we can't find the selected guard
        guard let g = ourGuards[cond] else { return true }
        
        return g(context)
    }
    
    private mutating func handleWithActionsAndGuardsEvent(
        actions: [String],
        cond: String) -> Bool {
        guard let ourActions = self.chart.actions else { return true }
        
        /// First we validate that we can make all the actions
        /// We don't want to make partial updates to the context]
        for action in actions {
            guard let act = ourActions[action] else { continue }
            let result = act(self.context)
            let guarded = handleWithGuardsEvent(context: result, cond: cond)
            if !guarded {
                /// Stop execution if we have a non guarded update
                return false
            }
        }
        
        handleWithActionsEvent(actions: actions)
        
        return true
    }
}

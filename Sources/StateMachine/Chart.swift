//
//  Chart.swift
//  
//
//  Created by Gustavo Ordaz on 11/10/19.
//

// MARK: Declarations

public struct Chart<State:Hashable, Actions:Hashable, Context> {
    public var id: String?
    public var initial: State
    public var context: Context
    public var states: [State: Transition?]
    public var actions: [String: ActionHandler]?
    public var guards: [String: (Context) -> Bool]?
    
    public init(
        id: String?,
        initial: State,
        context: Context,
        states: [State: Transition?],
        actions: [String: ActionHandler]? = nil,
        guards: [String: (Context) -> Bool]? = nil) {
        self.id = id
        self.initial = initial
        self.context = context
        self.states = states
        self.actions = actions
        self.guards = guards
    }
}

// MARK: - Interfaces

extension Chart {
    public typealias Transition = [TransitionTypes]
    public typealias Event = [Actions: VariadicState]
    public typealias ActionHandler = (Context) -> Context

    public enum TransitionTypes {
        case on(Event)
        case type(String)
    }

    public enum VariadicState {
        case simple(State)
        case withContext(target: State, action: ActionHandler)
        case withActions(target: State, actions: [String])
        case withGuards(target: State, cond: String)
        case withActionsAndGuards(
            target: State,
            actions: [String],
            cond: String)
    }
}

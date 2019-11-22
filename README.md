# StateMachine

**⚠️⚠️⚠️ This is still a work in progress ⚠️⚠️⚠️**

## Usage

### Import

```swift
import StateMachine
```

### Creating a Chart

```swift
enum LightStates {
    case green
    case yellow
    case red
}

enum LightActions {
    case timer
}

let chart = Chart(
    id: "lights",
    initial: LightStates.green,
    context: (),
    states: [
        .green: [
            .on([LightActions.timer: .simple(.yellow)])
        ],
        .yellow: [
            .on([.timer: .simple(.red)])
        ],
        .red: [
            .on([.timer: .simple(.green)])
        ],
    ]
)
```

We use `LightStates.green` and `LightActions.timer` here to take advantage of 
swift's type inference but we could also do:

```swift
let chart = Chart<LightStates, LightActions, ()>(
    id: "lights",
    initial: .green,
    context: (),
    states: [
        .green: [.on([.timer: .simple(.yellow)])],
        .yellow: [.on([.timer: .simple(.red)])],
        .red: [.on([.timer: .simple(.green)])],
    ]
)
```

### Creating a Machine

To create a Machine you need to pass a reference to a previously created chart

```swift
var machine = Machine(forChart: chart)
```

### State transitions

To transition from a state to another we call the `transition` method on Machine:

```swift
let result = machine.transition(state: machine.initial, event: .timer)
```

or, if you don't need the resulting state after the transition:

```swift
machine.transition(from: machine.initial, with: .timer)
```
I know, it is a bit confusing, if you have a better solution please file and issue or create a PR
🙏.

### Actions

State machines are great for creating strict rules of how our programs should behave, but,
the reality is that the world is a messy place, for instance, we can create a Context that holds
values that can be mutated by actions, ie:

```swift
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
    context: (0),
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
        // Two ways of representing finite states
        .success: nil,
        .cancelled: [
            .type("final")
        ],
        .failure: [
            .on([
                .retry: .withContext(
                    target: .loading,
                    action: { (count) in (count + 1) }),
                .reject: .simple(.cancelled)
            ])
        ],
    ]
)
```

Here, every time we call `.retry` on `.failure` we will execute a side effect of incrementing
our `count` property on the Context.

**Actions on entry**

TODO...

**Actions on exit**

TODO...

**Reuse actions**

For reusing actions we can declare a dictionary like so:

```swift
let fetchChart = Chart(
    id: "fetch",
    initial: FetchStates.idle,
    context: (0),
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
        // Two ways of representing finite states
        .success: nil,
        .cancelled: [
            .type("final")
        ],
        .failure: [
            .on([
                .retry: .withActions(
                    target: .loading,
                    actions: ["incrementCounter"]
                ),
                .reject: .simple(.cancelled)
            ])
        ],
    ],
    actions: [
        "incrementCounter": { (count) in (count + 1) }
    ]
)
```

### Guarded transitions

Guards are conditions we can set to prevent state transitions, ie:

```swift
enum CounterStates {
    case active
}

enum CounterActions {
    case increment
    case decrement
}

let guardedCounter = Chart(
    id: "counter",
    initial: CounterStates.active,
    context: (0),
    states: [
        .active: [
            .on([
                CounterActions.increment: .withActions(
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
```

So, guards ar functions that receive the current context and return a `Bool` where `true`
represents a valid transition and `false` the other way.

### Context

As I said before, Context allows us to hold values that can be mutated by Actions, this is
known as [extended state](https://en.wikipedia.org/wiki/UML_state_machine#Extended_states).

Context can hold any type of value but, is muche preferred to use tuples to avoid typecasting
when you need it to have many values.

## Credits

Based on [xstate](https://github.com/davidkpiano/xstate) by 
[@davidkpiano](https://twitter.com/davidkpiano)

StateMachine is licensed under the MIT license; see LICENSE for more information.

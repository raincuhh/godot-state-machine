# FiniteStateMachine

## Overview

The `StateMachine` class provides a modular way to manage different states in your game logic.
Each state is defined with three optional callbacks:

* `enter_state`: called when entering the state
* `normal`: called every frame while in the state (via `update()`)
* `leave_state`: called when exiting the state

This pattern allows for clean separation of logic and easy extensibility.

---

## Class Definition

```gdscript
class_name StateMachine
extends RefCounted
```

### Internal Structure

| Property               | Type         | Description                                          |
| ---------------------- | ------------ | ---------------------------------------------------- |
| `_states`              | `Dictionary` | Holds all registered states (`String` → `StateFlow`) |
| `_state_callables`     | `Dictionary` | Maps callables to their state names                  |
| `_current_state_name`  | `String`     | The currently active state                           |
| `_previous_state_name` | `String`     | The previously active state                          |

---

## StateFlow

Each state is represented by a `StateFlow` object:

```gdscript
class StateFlow:
	var name: String
	var normal: Variant
	var enter_state: Variant
	var leave_state: Variant
```

* `name`: Name of the state
* `normal`: Callable run every frame during the state
* `enter_state`: Callable triggered when entering
* `leave_state`: Callable triggered when exiting

---

## Usage Example

Example of a playercontroller for a simple platformer.

```gdscript
extends CharacterBody2D

@onready var state_machine: StateMachine = StateMachine.new()

var speed := 200.0
var jump_force := -400.0
var gravity := 900.0
var velocity: Vector2 = Vector2.ZERO

func _ready():
	# Define player states
	state_machine.add_states("idle", _state_idle, _enter_idle, _leave_idle)
	state_machine.add_states("move", _state_move, _enter_move, _leave_move)
	state_machine.add_states("jump", _state_jump, _enter_jump, _leave_jump)

	# Set starting state
	state_machine.set_initial_state("idle")

func _physics_process(delta):
	state_machine.update(delta)
	move_and_slide()

func _enter_move(delta):
	print("Entered Move")

func _state_move(delta):
	var direction := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.x = direction * speed

	if direction == 0:
		return "idle"
	if Input.is_action_just_pressed("jump"):
		return "jump"

func _leave_move(delta):
	print("Leaving Move")

func _enter_jump(delta):
	print("Entered Jump")
	velocity.y = jump_force

func _state_jump(delta):
	velocity.y += gravity * delta
	if is_on_floor():
		return "idle"

func _leave_jump(delta):
	print("Leaving Jump")
```

To update the current state each frame:

```gdscript
func _process(delta):
	state_machine.update(delta)
```

To change states:

```gdscript
state_machine.change_state("move", delta)
```
Or
```gdscript
state_machine.change_state(function_callback_name, delta)
```

---

## Core Methods

### `add_states(p_state_name: String, p_normal: Variant, p_enter_state: Variant, p_leave_state: Variant) -> void`

Registers a new state with its associated callbacks.

**Example:**

```gdscript
state_machine.add_states("jump", on_jump, on_enter_jump, on_leave_jump)
```

---

### `update(p_delta: float) -> void`

Runs the current state’s `normal` function every frame.
If that function returns a state name, a transition occurs automatically.

**Example (inside a state):**

```gdscript
func idle_state(delta):
	if Input.is_action_pressed("move"):
		return "move"
```

---

### `change_state(p_state: Variant, p_delta: float) -> void`

Manually transition to another state by name or by passing a registered callable.

---

### `set_initial_state(p_state: Variant) -> void`

Sets the starting state of the machine.

---

### `get_current_state_name() -> String`

Returns the name of the currently active state.

---

### `get_previous_state_name() -> String`

Returns the name of the previously active state.

---

## State Transition Flow

```text
leave_state() → enter_state() → normal() [every frame]
```

### Example Log:

```
Leaving Idle
Entered Move
Moving...
Moving...
```

---

## Warnings

* Make sure every state name is **unique**.
* Unregistered or invalid state transitions will log a warning.
* Always call `update(delta)` every frame to keep the state machine running.

---

## Suggested Use Cases

* Player movement systems (idle, run, jump, attack)
* Enemy AI behaviors (patrol, chase, attack)
* UI flow control (menus, dialogs, transitions)
* Animation controllers

---

## License

Licensed under MIT.
You’re free to use and modify it in your projects with attribution.

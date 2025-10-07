class_name StateMachine
extends Node

# made by rain
# A simple state machine system for managing states in a game.
# This implementation allows you to define states with their corresponding enter, leave, and normal behaviors,
# and handles transitions between states.

class_name StateMachine
extends RefCounted

var _states: Dictionary = {}
var _state_callables: Dictionary = {}
var _current_state_name: String = ""
var _previous_state_name: String = ""

func update(p_delta: float) -> void:
	if _current_state_name == "":
		return

	var flow: StateFlow = _states[_current_state_name]
	if flow.normal is Callable && flow.normal.is_valid():
		var next_state = flow.normal.call(p_delta)
		if next_state:
			change_state(next_state, p_delta)

func add_states(p_state_name: String, p_normal: Variant, p_enter_state: Variant, p_leave_state: Variant) -> void:
	var flow: StateFlow = StateFlow.new(p_state_name, p_normal, p_enter_state, p_leave_state)
	_states[p_state_name] = flow
	if p_normal is Callable && p_normal.is_valid():
		_state_callables[p_normal] = p_state_name

func change_state(p_state: Variant, p_delta: float) -> void:
	var state_name: String = ""

	if typeof(p_state) == TYPE_STRING:
		state_name = p_state
	elif p_state is Callable && _state_callables.has(p_state):
		state_name = _state_callables[p_state]
	else:
		push_warning("Invalid or unregistered state: %s" % str(p_state))
		return

	if !_states.has(state_name):
		push_warning("Attempted to change to unknown state: %s" % state_name)
		return

	call_deferred("set_state", _states[state_name], p_delta)

func set_state(p_state: StateFlow, p_delta: float = 0) -> void:
	if _current_state_name != "":
		var current_flow: StateFlow = _states[_current_state_name]
		if current_flow.leave_state is Callable && current_flow.leave_state.is_valid():
			current_flow.leave_state.call(p_delta)
		_previous_state_name = _current_state_name

	_current_state_name = p_state.name
	if p_state.enter_state is Callable && p_state.enter_state.is_valid():
		p_state.enter_state.call(p_delta)

func set_initial_state(p_state: Variant):
	if typeof(p_state) == TYPE_STRING:
		if _states.has(p_state):
			set_state(_states[p_state])
		else:
			push_warning("Unknown initial state: %s" % p_state)
	elif p_state is Callable && _state_callables.has(p_state):
		var name = _state_callables[p_state]
		set_state(_states[name])
	else:
		push_warning("Invalid initial state type: %s" % str(p_state))

func get_current_state_name() -> String:
	return _current_state_name

func get_previous_state_name() -> String:
	return _previous_state_name

class StateFlow:
	var name: String
	var normal: Variant
	var enter_state: Variant
	var leave_state: Variant

	func _init(p_name: String, p_normal: Variant, p_enter_state: Variant, p_leave_state: Variant):
		name = p_name
		normal = p_normal
		enter_state = p_enter_state
		leave_state = p_leave_state

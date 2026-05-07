# Game state interface - all states implement this
# Provides enter/exit/update pattern for state machine

class_name GameState

extends RefCounted


# === Signals ===

signal transition_requested(next_state: String)
signal state_completed(result: Dictionary)


# === Required Properties ===

var state_name: String = "unknown"
var is_active: bool = false


# === Required Methods ===

func enter(context: Dictionary) -> void:
	is_active = true
	_setup_ui(context)
	_connect_signals(context)


func exit() -> void:
	is_active = false
	_disconnect_signals()


func update(delta: float) -> void:
	pass


# === Virtual Methods ===

func _setup_ui(context: Dictionary) -> void:
	pass


func _connect_signals(context: Dictionary) -> void:
	pass


func _disconnect_signals() -> void:
	pass


# === Transition Helpers ===

func request_transition(next_state: String) -> void:
	transition_requested.emit(next_state)


func complete_with_result(result: Dictionary) -> void:
	state_completed.emit(result)
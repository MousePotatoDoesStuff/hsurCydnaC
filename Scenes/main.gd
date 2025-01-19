extends Control


@export var play_button:Button
@export var random_buttons:Array[Button]

func _ready() -> void:
	assert(play_button)


func _process(_delta: float) -> void:
	pass


func toggle_play_button(status: bool) -> void:
	play_button.disabled=not status
	toggle_random_buttons(status)


func toggle_random_buttons(status: bool) -> void:
	play_button.disabled=not status

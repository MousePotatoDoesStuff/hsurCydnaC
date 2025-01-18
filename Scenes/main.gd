extends Control


@export var play_button:Button
@export var random_buttons:Array[Button]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(play_button)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func toggle_play_button(status: bool) -> void:
	play_button.disabled=not status
	toggle_random_buttons(status)


func toggle_random_buttons(status: bool) -> void:
	play_button.disabled=not status

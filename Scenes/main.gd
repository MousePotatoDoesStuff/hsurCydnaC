extends Control


@export var play_button:Button
@export var random_buttons:Array[Button]

@export var score_text:RichTextLabel
@export var win_text:RichTextLabel
var best:int=999999999

func _ready() -> void:
	assert(play_button)
	assert(score_text)


func _process(_delta: float) -> void:
	pass


func toggle_play_button(status: bool) -> void:
	play_button.disabled=not status
	toggle_random_buttons(status)


func toggle_random_buttons(status: bool) -> void:
	play_button.disabled=not status


func display_score(score: int) -> void:
	score_text.text="[center]Score: "+str(score)



func win(score: int) -> void:
	var msg="\nNew best!"
	if score<self.best:
		self.best=score
	else:
		msg="\nBest: "+str(self.best)
	win_text.text="[center]Score: "+str(score)+msg
	$ColorRect.show()


func restart() -> void:
	$ColorRect.hide()
	$"Center/Physical Board".restart()

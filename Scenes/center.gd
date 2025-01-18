extends Control


@export var board:Node2D
@export var board_size:Vector2=Vector2.ONE*1280
@export var main:Control
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(board)
	assert(main)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.size.y=self.size.x
	self.position.y=(main.size.y-self.size.y)/2
	board.position=self.size/2
	board.scale=self.size/board_size
	print(board.scale, self.size)
	pass

func set_board_size(new_size: Vector2):
	self.board_size=board_size

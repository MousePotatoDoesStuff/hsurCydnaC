class_name BoardLayer extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func fill_square(top_left:Vector2i,bottom_right_lim:Vector2i,value:Vector2i):
	for i in range(top_left.x,bottom_right_lim.x):
		for j in range(top_left.y,bottom_right_lim.y):
			var loc:Vector2i=Vector2i(i,j)
			self.set_cell(loc,0,value)

func reset_blank(halfsize:Vector2i):
	var outer_limit:Vector2i=halfsize+Vector2i.ONE
	self.fill_square(-outer_limit,outer_limit,Vector2i.ONE*3)
	self.fill_square(-halfsize+Vector2i.UP,halfsize,Vector2i.ZERO)

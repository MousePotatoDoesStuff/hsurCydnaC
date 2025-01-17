extends Node2D


@export var static_layer:BoardLayer
@export var falling_layer:BoardLayer
@export var allow_layer:BoardLayer
@export var destroyed_layer:BoardLayer
@export var halfsize:Vector2i=Vector2i(4,4)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(static_layer)
	assert(falling_layer)
	assert(allow_layer)
	assert(destroyed_layer)
	search_for_best_col()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func swap_nodes(first:Vector2i, second: Vector2i):
	var val1:Vector2i=static_layer.get_cell_atlas_coords(first)
	var val2:Vector2i=static_layer.get_cell_atlas_coords(second)
	print(val1,val2)
	static_layer.set_cell(first,0,val2)
	static_layer.set_cell(second,0,val1)
	val1=static_layer.get_cell_atlas_coords(first)
	val2=static_layer.get_cell_atlas_coords(second)
	print(val1,val2)

func end_swap_nodes(first:Vector2i, second:Vector2i):
	return
	
func search_for_best_col(row_ind=0)->int:
	var last:int=-self.halfsize[1]
	var cur_cell=Vector2i(row_ind,last)
	var lastval=self.static_layer.get_cell_atlas_coords(cur_cell)
	while cur_cell.y!=self.halfsize[1]:
		var curval=self.static_layer.get_cell_atlas_coords(cur_cell)
		self.static_layer.set_cell(cur_cell,0,Vector2i.RIGHT)
		cur_cell+=Vector2i.DOWN
	return 0

func search_and_destroy_row(row_ind=0):
	var last=0

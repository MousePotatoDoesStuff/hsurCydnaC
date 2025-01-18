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
	search_for_best_line(0,0)
	search_for_best_line(1,0)
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
	
func search_for_best_line(dimension:int,row_ind:int)->int:
	dimension%=2
	var DIRECTION=[Vector2i.DOWN,Vector2i.RIGHT][dimension]
	
	var last:int=-self.halfsize[dimension]
	var cur_cell=Vector2i(row_ind,last)
	var lastval=self.static_layer.get_cell_atlas_coords(cur_cell)
	var best:int=0
	
	while cur_cell[1-dimension]<=self.halfsize[1-dimension]:
		var curval=self.static_layer.get_cell_atlas_coords(cur_cell)
		self.static_layer.set_cell(cur_cell,0,Vector2i.ZERO)
		if curval!=lastval:
			var curdiff=cur_cell.y-last
			last=cur_cell.y
			lastval=curval
			if best<curdiff:
				best=curdiff
			self.static_layer.set_cell(cur_cell,0,Vector2i.ONE*3)
		cur_cell+=DIRECTION
	return best

func search_and_destroy_row(row_ind=0):
	var last=0

func search_for_best_dimension(dimension:int):
	var res=[]
	var half=self.halfsize[dimension]
	for i in range(half*2):
		res.append(true)
	for i in range(-half,half):
		var cur_res=self.search_for_best_line(int)
		if cur_res<5:
			res[i]=cur_res==4
			continue
		return []
	return res

func search_and_destroy():
	var whole_cols:array[bool]=self.search_for_best_dimension(0)
	var whole_rows:array[bool]=self.search_for_best_dimension(1)

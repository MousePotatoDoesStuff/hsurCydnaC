extends Node2D


signal board_ready_signal(status:bool)
signal board_editable_signal(status:bool)

@export var static_layer:BoardLayer
@export var falling_layer:BoardLayer
@export var allow_layer:BoardLayer
@export var destroyed_layer:BoardLayer
@export var halfsize:Vector2i=Vector2i(4,4)
@export var FALL_SPEED:float=10
var fall_time:float=-1
var offset:float=0
var editable:bool=true
var empties:int=0
var last_edited=Vector2i.ONE*10000001
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(static_layer)
	assert(falling_layer)
	assert(allow_layer)
	assert(destroyed_layer)
	for layer in [static_layer,falling_layer,allow_layer,destroyed_layer]:
		layer.halfsize=halfsize
		layer.show()
	destroyed_layer.hide()
	apply_move()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if self.editable:
		change_tile()
	if self.fall_time<-0.5:
		falling_layer.position=Vector2.ZERO
		return
	self.fall_time+=delta
	var new_offset=fall_time*FALL_SPEED
	var still_falling=true
	if int(new_offset)>int(self.offset):
		still_falling=self.static_layer.stop_floating(self.falling_layer,int(new_offset))
	self.offset=new_offset
	var t_size=falling_layer.tile_set.tile_size
	falling_layer.position=Vector2(t_size)*Vector2(0,self.offset)
	if not still_falling:
		self.fall_time=-1.0
		self.offset=0.0
		self.end_move()

func apply_move():
	self.editable=false
	self.board_ready_signal.emit(false)
	self.empties+=static_layer.search_and_mark(destroyed_layer)
	print(self.empties)
	static_layer.conditional_fill(destroyed_layer,Vector2i.RIGHT,Vector2i.ZERO)
	destroyed_layer.fill_square(-self.halfsize,self.halfsize,Vector2i.ZERO)
	falling_layer.fill_square(-halfsize,halfsize,Vector2i.ZERO)
	static_layer.swap_floating(falling_layer)
	allow_layer.fill_square(-self.halfsize,self.halfsize,Vector2i.ZERO)
	self.fall_time=0.0

func end_move():
	allow_layer.conditional_fill(static_layer,Vector2i.ZERO,Vector2i.RIGHT)
	self.editable=true
	self.board_editable_signal.emit(true)
	if empties==0:
		self.board_ready_signal.emit(true)
		return

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

func change_tile():
	if not Input.is_mouse_button_pressed(1):
		last_edited=Vector2i.ONE*10000001
		return
	var local_position = to_local(get_global_mouse_position())
	var grid_position = self.static_layer.local_to_map(local_position)
	if grid_position==self.last_edited:
		return
	for i in range(2):
		if grid_position[i] not in range(-self.halfsize[i],self.halfsize[i]):
			return
	self.last_edited=grid_position
	if self.allow_layer.get_cell_atlas_coords(grid_position)==Vector2i.ZERO:
		return
	var current=self.static_layer.get_cell_atlas_coords(grid_position)
	if current==Vector2i.ZERO:
		empties-=1
		if empties==0:
			self.board_ready_signal.emit(true)
	var ind=current.y*3+current.x
	ind%=8
	ind+=1
	var new=Vector2i(ind%3,ind/3)
	self.static_layer.set_cell(grid_position,0,new)

func randomise(force:bool):
	var first=self.halfsize[0]
	var second=self.halfsize[1]
	for i in range(-first,first):
		for j in range(-second,second):
			var cur:Vector2i=Vector2i(i,j)
			if self.allow_layer.get_cell_atlas_coords(cur)==Vector2i.ZERO:
				break
			if not force and self.static_layer.get_cell_atlas_coords(cur)!=Vector2i.ZERO:
				continue
			var value=randi_range(1,8)
			var new=Vector2i(value%3,value/3)
			self.static_layer.set_cell(cur,0,new)

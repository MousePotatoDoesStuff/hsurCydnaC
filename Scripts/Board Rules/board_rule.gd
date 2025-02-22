class_name BoardRule extends Object

var first_req:int
var second_req:int
var first_limit:int
var second_limit:int
var score_per_tile:int=1
func _init(
	first_requirement:int, 
	second_requirement:int, 
	limit_first:int=1<<31, 
	limit_second:int=1<<31
	) -> void:
	self.first_req = first_requirement  
	self.second_req = second_requirement  
	self.first_limit = limit_first  
	self.second_limit = limit_second
	return

func checkCell(board:BoardLayer,origin:BoardLayer,cell:Vector2i)->Vector2i:
	var value=origin.get_cell_atlas_coords(cell)
	var res=Vector2i.ZERO
	for i in range(2):
		if value[i]<first_req:
			continue
		if value[i]>=first_limit:
			continue
		if value[1-i]<second_req:
			continue
		if value[1-i]>=second_limit:
			continue
		res[i]=1
	return res

func applyCell(board:BoardLayer,origin:BoardLayer,cell:Vector2i,destination:BoardLayer)->int:
	var res=self.checkCell(board,origin,cell)
	if res==Vector2i.ZERO:
		return 0
	var ret=0
	if destination.get_cell_atlas_coords(cell)==Vector2i.ZERO:
		ret=1
	destination.set_cell(cell,0,Vector2i.RIGHT)
	return ret

func apply(board:BoardLayer,origin:BoardLayer,destination:BoardLayer)->int:
	var half=origin.halfsize
	var res:int=0
	for i in range(-half[0],half[0]):
		for j in range(-half[1],half[1]):
			res+=self.applyCell(board,origin,Vector2i(i,j),destination)
	return res*self.score_per_tile

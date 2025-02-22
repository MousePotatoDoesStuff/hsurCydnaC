class_name DeleteTypeRule extends BoardRule

var del_count:int=1<<31

func _init(
	first_requirement:int, 
	second_requirement:int, 
	limit_first:int=1<<31, 
	limit_second:int=1<<31,
	delete_per_occurence:int=1<<31
	) -> void:

	self.first_req = first_requirement  
	self.second_req = second_requirement  
	self.first_limit = limit_first  
	self.second_limit = limit_second
	self.del_count = delete_per_occurence
	return

func apply(board:BoardLayer,origin:BoardLayer,destination:BoardLayer)->int:
	var half=origin.halfsize
	var deleted={}
	for i in range(-half[0],half[0]):
		for j in range(-half[1],half[1]):
			var loc=Vector2i(i,j)
			var cell=board.get_cell_atlas_coords(loc)
			var data=self.checkCell(board,origin,loc)
			if data==Vector2i.ZERO:
				continue
			if cell not in deleted:
				deleted[cell]=0
			deleted[cell]+=del_count
	var res=0
	for i in range(-half[0],half[0]):
		for j in range(-half[1],half[1]):
			var loc=Vector2i(i,j)
			var cell=board.get_cell_atlas_coords(loc)
			if cell not in deleted:
				continue
			var del=deleted[cell]-1
			if del==0:
				deleted.erase(cell)
			else:
				deleted[cell]=del
			print(loc)
			destination.set_cell(loc,0,Vector2i.RIGHT)
			res+=1
	return res*self.score_per_tile

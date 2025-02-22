class_name DeleteAllRule extends BoardRule

func apply(board:BoardLayer,origin:BoardLayer,destination:BoardLayer)->int:
	var half=origin.halfsize
	var cancel=true
	for i in range(-half[0],half[0]):
		for j in range(-half[1],half[1]):
			var loc=Vector2i(i,j)
			var cell=board.get_cell_atlas_coords(loc)
			var data=self.checkCell(board,origin,loc)
			if data==Vector2i.ZERO:
				continue
			cancel=false
	if cancel:
		return 0
	destination.fill_square(-half,half,Vector2i.RIGHT)
	return score_per_tile

class_name LineBoardRule extends BoardRule


func apply(board:BoardLayer,origin:BoardLayer,destination:BoardLayer)->int:
	var confirmed_lines_x={}
	var confirmed_lines_y={}
	var half=origin.halfsize
	for i in range(-half[0],half[0]):
		for j in range(-half[1],half[1]):
			var data=self.checkCell(board,origin,Vector2i(i,j))
			if data[0]:
				confirmed_lines_x[j]=true
			if data[1]:
				confirmed_lines_y[i]=true
			self.applyCell(board,origin,Vector2i(i,j),destination)
	var res=0
	for i in range(-half[0],half[0]):
		var blank=i not in confirmed_lines_y
		for j in range(-half[1],half[1]):
			if blank and j not in confirmed_lines_x:
				continue
			var cell=Vector2i(i,j)
			if destination.get_cell_atlas_coords(cell)==Vector2i.ZERO:
				res+=1
				destination.set_cell(cell,0,Vector2i.RIGHT)
	return res*self.score_per_tile

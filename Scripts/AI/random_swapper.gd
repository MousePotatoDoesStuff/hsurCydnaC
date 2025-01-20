class_name RandomSwapper extends iSwapper

func make_swap(grid:BoardLayer)->Array[Vector2i]:
	var direction_index=randi_range(0,1)
	var downright_limit=grid.halfsize-Vector2i.ONE
	if direction_index==0:
		downright_limit.y-=1
	else:
		downright_limit.x-=1
	var x1=randi_range(-grid.halfsize.x,downright_limit.x)
	var y1=randi_range(-grid.halfsize.y,downright_limit.y)
	var v1=Vector2i(x1,y1)
	var v2=v1+[Vector2i.DOWN,Vector2i.RIGHT][direction_index]
	print(direction_index,downright_limit,v1,v2)
	return [v1,v2]

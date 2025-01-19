class_name RandomSwapper extends iSwapper

func make_swap(grid:BoardLayer)->Array[Vector2i]:
	var direction_index=randi_range(0,3)
	var downright_limit=-grid.halfsize
	var upleft_limit=grid.halfsize-Vector2i.ONE
	match direction_index:
		0:
			upleft_limit.y+=1
		1:
			downright_limit.y-=1
		2:
			upleft_limit.x+=1
		3:
			downright_limit.x-=1
	var x1=randi_range(upleft_limit.x,downright_limit.x)
	var y1=randi_range(upleft_limit.y,downright_limit.y)
	var v1=Vector2i(x1,y1)
	var v2=v1+[Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT][direction_index]
	return [v1,v2]

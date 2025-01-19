class_name iSwapper extends Object

func make_swap(grid:BoardLayer)->Array[Vector2i]:
	assert(false,"AI not implemented!")
	return [Vector2i.ZERO,Vector2i.ZERO]

func is_valid_swap(swap:Array[Vector2i]):
	if len(swap)!=2:
		return false
	var diff:Vector2i=swap[0]-swap[1]

func check_swap(grid:BoardLayer)->Array[Vector2i]:
	var res:Array[Vector2i]=self.make_swap(grid)
	if is_valid_swap(res):
		return res
	return [Vector2i.ZERO,Vector2i.ZERO]

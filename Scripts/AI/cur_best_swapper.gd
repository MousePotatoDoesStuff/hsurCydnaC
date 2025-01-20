class_name CurBestSwapper extends iSwapper

func make_swap(grid:BoardLayer)->Array[Vector2i]:
	return grid.get_best_swap()

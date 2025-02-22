class_name BoardLayer extends TileMapLayer


var halfsize:Vector2i

# Setters ---------------------------------------------------------------------------------------- #
func reset_blank(in_halfsize:Vector2i=Vector2i.ZERO, null_value:Vector2i=Vector2i.ZERO):
	if in_halfsize!=Vector2i.ZERO:
		halfsize=in_halfsize
	var outer_limit:Vector2i=halfsize+Vector2i.ONE
	# self.fill_square(-outer_limit,outer_limit,Vector2i.ONE*3)
	self.fill_square(-halfsize,halfsize,null_value)

func fill_square(top_left:Vector2i,bottom_right_lim:Vector2i,value:Vector2i):
	for i in range(top_left.x,bottom_right_lim.x):
		for j in range(top_left.y,bottom_right_lim.y):
			var loc:Vector2i=Vector2i(i,j)
			self.set_cell(loc,0,value)

func conditional_fill(reference_board:BoardLayer,required:Vector2i,fill:Vector2i):
	var first=reference_board.halfsize[0]
	var second=reference_board.halfsize[1]
	for i in range(-first,first):
		for j in range(-second,second):
			var cell=Vector2i(i,j)
			if reference_board.get_cell_atlas_coords(cell)==required:
				self.set_cell(cell,0,fill)

# Getters ---------------------------------------------------------------------------------------- #
func step_match(second:Vector2i,delta:Vector2i,value:Vector2i):
	while self.get_cell_atlas_coords(second)==value:
		second+=delta
	return second
func seek_lines(first:Vector2i,delta:Vector2i,value:Vector2i):
	var second:Vector2i=self.step_match(first+delta,delta,value)
	while self.get_cell_atlas_coords(second)==value:
		second+=delta
	var res1=(second-first).length()
	delta*=delta
	delta-=Vector2i.ONE
	second=self.step_match(first+delta,delta,value)
	first=self.step_match(first-delta,-delta,value)
	var res2=(second-first).length()-1
	var res=0
	if res2>=5:
		return self.halfsize.x*self.halfsize.y*4
	if res2>=3:
		res+=res2
	if res1>=3:
		if res!=0:
			res-=1
		res=res1
	return res

func evaluate_swap(first:Vector2i,second:Vector2i):
	var delta=second-first
	var first_value=self.get_cell_atlas_coords(first)
	var second_value=self.get_cell_atlas_coords(second)
	assert(delta.length_squared()==1)
	var res1=self.seek_lines(first,-delta,second_value)
	var res2=self.seek_lines(second,delta,first_value)
	return res1+res2

func get_best_swap():
	var best:Array[Vector2i]=[Vector2i.ZERO,-Vector2i.RIGHT]
	var best_val:int=0
	for direction_index in range(2):
		var downright_limit=self.halfsize
		if direction_index==0:
			downright_limit.y-=1
		else:
			downright_limit.x-=1
		for x1 in range(-self.halfsize.x,downright_limit.x):
			for y1 in range(-self.halfsize.y,downright_limit.y):
				var v1=Vector2i(x1,y1)
				var v2=v1+[Vector2i.DOWN,Vector2i.RIGHT][direction_index]
				var cur=self.evaluate_swap(v1,v2)
				if cur<=best_val:
					continue
				best=[v1,v2]
				best_val=cur
	return best

func cmb_line(dimension:int,row_ind:int,marked_board:BoardLayer):
	dimension%=2
	var DIRECTION=[Vector2i.RIGHT,Vector2i.DOWN][dimension]
	
	var half=self.halfsize[dimension]
	var cur_cell:Vector2i=-self.halfsize
	cur_cell[1-dimension]=row_ind
	var last_cell:Vector2i=cur_cell
	var lastval=self.get_cell_atlas_coords(cur_cell)
	cur_cell-=DIRECTION
	while cur_cell[dimension] < half:
		cur_cell+=DIRECTION
		var curval = self.get_cell_atlas_coords(cur_cell)
		if curval == lastval:
			continue
		lastval=curval
		var diff = cur_cell - last_cell
		var seq_length = max(diff.x,diff.y)
		while last_cell!=cur_cell:
			var old:Vector2i=marked_board.get_cell_atlas_coords(last_cell)
			old[dimension]=seq_length
			marked_board.set_cell(last_cell,0,old)
			last_cell+=DIRECTION

func cmb_dim(dimension:int,marked_board:BoardLayer):
	var half=self.halfsize[1-dimension]
	for i in range(-half,half):
		cmb_line(dimension,i,marked_board)

func create_marked_board(marked_board:BoardLayer):
	assert(self.halfsize!=Vector2i.ZERO)
	assert(marked_board.halfsize!=Vector2i.ZERO)
	for i in range(2):
		cmb_dim(i,marked_board)
	return

# Falling board interactions --------------------------------------------------------------------- #
func swap_floating(falling_board:BoardLayer):
	var first=falling_board.halfsize[0]
	var second=falling_board.halfsize[1]
	for i in range(-first,first):
		var floating=false
		for j in range(second-1,-second-1,-1):
			var cell=Vector2i(i,j)
			var value=self.get_cell_atlas_coords(cell)
			if not floating:
				floating=value==Vector2i.ZERO
				continue
			falling_board.set_cell(cell,0,value)
			self.set_cell(cell,0,Vector2i.ZERO)
	return

func stop_floating(falling_board:BoardLayer, offset:int)->bool:
	var first=falling_board.halfsize[0]
	var second=falling_board.halfsize[1]
	var lowest=second-offset
	var still_falling:bool=false
	for i in range(-first,first):
		var fall_continued=false
		for j in range(lowest,-second-1,-1):
			var j2=j+offset
			var other_loc=Vector2i(i,j)
			var this_loc=Vector2i(i,j2)
			var other_value=falling_board.get_cell_atlas_coords(other_loc)
			var this_value=self.get_cell_atlas_coords(this_loc)
			if fall_continued:
				fall_continued=this_value==Vector2i.ZERO
				if other_value!=Vector2i.ZERO:
					still_falling=true
				continue
			if other_value!=Vector2i.ZERO:
				assert(this_value==Vector2i.ZERO)
				self.set_cell(this_loc,0,other_value)
				falling_board.set_cell(other_loc,0,Vector2i.ZERO)
				continue
			fall_continued=this_value==Vector2i.ZERO
	return still_falling

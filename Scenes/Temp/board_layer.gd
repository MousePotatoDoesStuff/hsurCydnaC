class_name BoardLayer extends TileMapLayer


var halfsize:Vector2i

# Setters ---------------------------------------------------------------------------------------- #
func reset_blank(in_halfsize:Vector2i=Vector2i.ZERO):
	if in_halfsize!=Vector2i.ZERO:
		halfsize=in_halfsize
	var outer_limit:Vector2i=halfsize+Vector2i.ONE
	self.fill_square(-outer_limit,outer_limit,Vector2i.ONE*3)
	self.fill_square(-halfsize+Vector2i.UP,halfsize,Vector2i.ZERO)

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
func search_for_best_line(dimension:int,row_ind:int)->int:
	dimension%=2
	var DIRECTION=[Vector2i.DOWN,Vector2i.RIGHT][dimension]
	
	var last:int=-self.halfsize[dimension]
	var cur_cell=[Vector2i(row_ind,last),Vector2i(last,row_ind)][dimension]
	var lastval=self.get_cell_atlas_coords(cur_cell)
	var best:int=0
	
	while cur_cell[1-dimension]<=self.halfsize[1-dimension]:
		var curval=self.get_cell_atlas_coords(cur_cell)
		if curval!=lastval:
			var cur=cur_cell[1-dimension]
			var curdiff=cur-last
			last=cur
			lastval=curval
			if best<5 and curdiff>=5:
				print("CLEAR BOARD!")
			if best<curdiff:
				best=curdiff
		cur_cell+=DIRECTION
	return best

func search_for_best_dimension(dimension:int):
	var res:Array[bool]=[]
	var half=self.halfsize[dimension]
	for i in range(half*2):
		res.append(true)
	for i in range(-half,half):
		var cur_res=self.search_for_best_line(dimension,i)
		if cur_res<5:
			res[i]=cur_res==4
			continue
		res=[]
		return res
	return res

func mark_line(dimension:int,row_ind:int,first,limit,output_board:BoardLayer):
	var cell=-self.halfsize
	cell[dimension]=row_ind
	var count=0
	for i in range(first,limit):
		cell[1-dimension]=i
		if output_board.get_cell_atlas_coords(cell)!=Vector2i.RIGHT:
			count+=1
		output_board.set_cell(cell,0,Vector2.RIGHT)
	return count

func mark_longs(dimension:int,row_ind:int,output_board:BoardLayer)->int:
	dimension%=2
	var DIRECTION=[Vector2i.DOWN,Vector2i.RIGHT][dimension]
	
	var last:int=-self.halfsize[dimension]
	var cur_cell=[Vector2i(row_ind,last),Vector2i(last,row_ind)][dimension]
	var lastval=self.get_cell_atlas_coords(cur_cell)
	var mark_count=0
	
	while cur_cell[1-dimension]<=self.halfsize[1-dimension]:
		var curval=self.get_cell_atlas_coords(cur_cell)
		if curval!=lastval:
			var cur=cur_cell[1-dimension]
			if cur-last>=3 and lastval!=Vector2i.ZERO:
				var temp=self.mark_line(dimension,row_ind,last,cur,output_board)
				mark_count+=temp
			last=cur
			lastval=curval
		cur_cell+=DIRECTION
	return mark_count

func mark_dimension(dimension:int,data:Array[bool],output_board:BoardLayer):
	var half=self.halfsize[dimension]
	var other_half=self.halfsize[1-dimension]
	var mark_count=0
	var temp=0
	for i in range(-half,half):
		if data[i]:
			temp=self.mark_line(dimension,i,-other_half,other_half,output_board)
		else:
			temp=self.mark_longs(dimension,i,output_board)
		mark_count+=temp
	return mark_count

func search_and_mark(output_board:BoardLayer):
	var whole_cols:Array[bool]=[]
	var whole_rows:Array[bool]=[]
	whole_cols=self.search_for_best_dimension(0)
	if not whole_cols.is_empty():
		whole_rows=self.search_for_best_dimension(1)
	if whole_rows.is_empty():
		self.fill_square(-self.halfsize,self.halfsize,Vector2i.ZERO)
		output_board.fill_square(-self.halfsize,self.halfsize,Vector2i.RIGHT)
		return self.halfsize[0]*self.halfsize[1]*4
	var mark_count=0
	mark_count+=self.mark_dimension(0,whole_cols,output_board)
	mark_count+=self.mark_dimension(1,whole_rows,output_board)
	# self.conditional_fill(output_board,Vector2i.ONE,Vector2i.ZERO)
	return mark_count

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

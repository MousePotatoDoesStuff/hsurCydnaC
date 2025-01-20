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
				print(best,best_val)
	return best

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

func search_for_best_substitution(dimension:int,use_next:bool,row_ind:int)->Vector3i:
	dimension%=2
	
	var used_one:Dictionary={}
	var used_one_first:Dictionary={}
	
	var last:int=-self.halfsize[dimension]
	var cur_cell=Vector2i.ONE*(-last)
	cur_cell[dimension]=row_ind
	var lastval=-Vector2i.RIGHT
	
	var best_pos:Vector2i=cur_cell
	var best_val:int=0
	
	var SIDE_MOVE:Vector2i=Vector2i.ZERO
	SIDE_MOVE[dimension]=1 if use_next else -1
	
	for i in range(-self.halfsize[dimension],self.halfsize[dimension]):
		cur_cell[1-dimension]=i
		var cur_val=self.get_cell_atlas_coords(cur_cell)
		for key in used_one:
			if key==cur_val:
				continue
			var used_loc:Vector2i=used_one[key]
			used_one.erase(key)
			var start:int=used_one_first[key]
			used_one_first.erase(key)
			var diff=i-start
			if diff>best_val:
				best_val=diff
				best_pos=used_loc
		var orthogonal:Vector2i=cur_cell+SIDE_MOVE
		var ort_val=self.get_cell_atlas_coords(orthogonal)
		if ort_val!=cur_val:
			used_one[ort_val]=i
			used_one_first[ort_val]=i if ort_val!=lastval else last
		if cur_val!=lastval:
			last=i
			lastval=cur_val
	return Vector3i(best_pos.x,best_pos.y,best_val)

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

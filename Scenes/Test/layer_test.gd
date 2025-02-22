extends Node2D
@export var static_layer:BoardLayer
@export var destroyed_layer:BoardLayer
@export var marked_layer:BoardLayer

var empties=0
var halfsize:Vector2i
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	for el in self.getAllLayers():
		assert(el)
	halfsize=Vector2i.ONE*4
	self.set_halfsizes()
	static_layer.create_marked_board(marked_layer)
	var rules:Array[BoardRule]=[
		BoardRule.new(3,0,4),
		LineBoardRule.new(4,0)
	]
	rules=[
		DeleteAllRule.new(5,0)
	]
	for rule in rules:
		self.empties+=rule.apply(static_layer,marked_layer,destroyed_layer)

func getAllLayers()->Array[BoardLayer]:
	return [
		static_layer,
		destroyed_layer,
		marked_layer
	]

func set_halfsizes():
	for el in self.getAllLayers():
		el.halfsize=self.halfsize


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

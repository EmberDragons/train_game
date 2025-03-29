extends AnimatedSprite2D

@export var ArrWeels : Array[Sprite2D]
@export var ArrShaders : Array[Sprite2D]
@export var speedMultiplyer : float =10


var side_h = []

var all_list
func _ready():
	all_list = copy(ArrWeels)
	var arr = copy(ArrShaders)
	all_list.append_array(arr)
	for i in range(len(all_list)):
		side_h.append("left")

func _process(delta: float) -> void:
	for i in range(len(all_list)):
		var obj = all_list[i]
		if flip_h == false:
			if side_h[i] == "right":
				side_h[i]="left"
				obj.position.x=-obj.position.x
			if obj in ArrWeels:
				obj.rotation+=(-delta*(get_parent().current_Speed**3)*speedMultiplyer)
		else:
			if side_h[i] == "left":
				side_h[i]="right"
				obj.position.x=-obj.position.x
			if obj in ArrWeels:
				obj.rotation+=(delta*(get_parent().current_Speed**3)*speedMultiplyer)

func copy(list):
	var new_l = []
	for elt in list:
		new_l.append(elt)
	return new_l

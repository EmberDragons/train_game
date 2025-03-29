extends Node


var last_length = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	calculate_children()
		

func _process(delta: float) -> void:
	if last_length != len(get_children()):
		last_length=len(get_children())
		calculate_children()

func calculate_children():
	for i in range(1,len(get_children())):
		get_child(i).train_forward = get_child(i-1)

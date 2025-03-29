extends Node2D

@export var time = 1.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if time>=0:
		time-=delta
	else:
		queue_free()

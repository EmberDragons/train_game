extends Node2D
@onready var cam: Camera2D = $"../Camera2D"

var cam_start_pos 

@export var size_in = 4.0
@export var size_out = 2.8

var t = 0
var inside : bool = false
var go = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cam_start_pos=cam.position


func _process(delta):
	
	
	
	#pos/zoom cam
	var speed = 5.0
	if inside==false:
		cam.zoom.x = lerp(cam.zoom.x, size_out, speed * delta)
		cam.zoom.y = lerp(cam.zoom.y, size_out, speed * delta)
		cam.position = lerp(cam.position, cam_start_pos, speed * delta)
	else:
		cam.zoom.x = lerp(cam.zoom.x, size_in, speed * delta)
		cam.zoom.y = lerp(cam.zoom.y, size_in, speed * delta)
		cam.position = lerp(cam.position, position, speed * delta)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("train"):
		if inside == false:
			inside = true
		else:
			inside = false

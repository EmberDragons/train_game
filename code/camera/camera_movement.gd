extends Camera2D

@export var move_speed = 1.0
@export var zoom_speed = 1.0
@export var MAX_ZOOM = 5.0
@export var MIN_ZOOM = 0.5
@export var MAX_DIST = 10

var is_dragging = false
var last_mouse_pos : Vector2

@onready var center_world: Node2D = $".."

@onready var track: Node = $"../track"

var right_input = false

func _unhandled_input(event: InputEvent) -> void:
	#for the mouse dragging mouvement:
	if event is InputEventMouseMotion:
		if is_dragging:
			var inter_pos = position -(event.position-last_mouse_pos)*move_speed
			if sqrt((inter_pos.x-center_world.position.x)**2+(inter_pos.y-center_world.position.y)**2)<MAX_DIST:
				position =inter_pos
				last_mouse_pos=event.position
		else:
			last_mouse_pos=event.position
	if Input.is_action_just_pressed("click") and track.is_placing == false:
		is_dragging=true
	if Input.is_action_just_pressed("click_right") and track.is_placing == false:
		is_dragging=true
		
	if Input.is_action_just_released("click"):
		is_dragging=false
		right_input=false
	if Input.is_action_just_released("click_right"):
		is_dragging=false
		right_input=true
	
	# for the zoom
	if Input.is_action_pressed("zoom_in"):
		zoom_in()
	if Input.is_action_pressed("zoom_out"):
		zoom_out()
	
func zoom_in():
	if zoom[0]<MIN_ZOOM:
		if move_speed>0.1:
			move_speed-=0.05
		zoom += Vector2(zoom_speed,zoom_speed)
func zoom_out():
	if zoom[0]>MAX_ZOOM:
		if move_speed<1.5:
			move_speed+=0.05
		zoom -= Vector2(zoom_speed,zoom_speed)

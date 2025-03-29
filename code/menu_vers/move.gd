extends CharacterBody2D

#Movement variables---------------------------------------------------------------------------------

#physics constants
var MAX_SPEED = 1.0
var STOP_SPEED = 0.002

var ACC := 0.01
var FRICTION := 0.003

@export var current_Speed = 0
var direction = "right"

var STATE = 0.0 #0 no speed, >0 add speed, <0 decrease speed (between -1 and 1)

#Turn variables----------------------------------------------------------------------------------
@onready var train_body: AnimatedSprite2D = $graphics
@onready var area_2d: Area2D = $AnimatedSprite2D/Area2D

var last_track 
var already_track = false
var new_rotation = 0

#speed control -----------------------------------------------------------------------------------
@onready var speed_ui: Label = $"../../ui/right_down/VBoxContainer/speed_control/Control/speed_text"
@onready var passenger_ui: Label = $"../../ui/right_top/Container/Control/PanelContainer2/people_text"
@onready var speed_controller: VSlider = $"../../ui/right_down/VBoxContainer/speed_control/Control/speed_controller"

@onready var top: Control = $"../../ui/right_down/VBoxContainer/speed_control/Control/top"
@onready var middle: Control = $"../../ui/right_down/VBoxContainer/speed_control/Control/middle"
@onready var bottom: Control = $"../../ui/right_down/VBoxContainer/speed_control/Control/bottom"

@onready var selector: Sprite2D = $"../../ui/right_down/VBoxContainer/speed_control/Control/selector"
@onready var side_select: Sprite2D = $"../../ui/right_down/VBoxContainer/speed_control/Control/side_select"
var start_scale = 0
var start_dist = 0

var add_speed : bool = true
var vectorDir : Vector2

#Smoke variables---------------------------------------------------------------------------------
@onready var smoke: CPUParticles2D = $graphics/smoke

@export var change_values = [0.6,0.9]




func _ready():
	smoke.position.x=-smoke.position.x
	train_body.flip_h=true
	
	start_scale = side_select.scale
	var vect = Vector2(Vector2(selector.position.x-70,selector.position.y-7)-side_select.position)
	start_dist = sqrt(vect.x**2+vect.y**2)

func update_ui():
	var new_pos=Vector2(0,0)
	if STATE>=0.5:
		new_pos = (STATE-0.5)*2*top.position+(1-(STATE-0.5)*2)*middle.position
	else:
		new_pos = (1-(STATE*2))*bottom.position+(STATE*2)*middle.position
	selector.position=new_pos
	
	var vect = Vector2(Vector2(selector.position.x-70,selector.position.y-7)-side_select.position)
	var new_dist = sqrt(vect.x**2+vect.y**2)
	var new_size = (start_scale*new_dist)/start_dist
	var angle = asin((selector.position.y-7-side_select.position.y)/new_dist)
	side_select.scale=new_size
	side_select.rotation = angle
	
	#update speed
	var last_speed = float(speed_ui.text.split(" ")[0])
	if abs(last_speed-(abs(current_Speed)*100))>=1.0:
		speed_ui.text=str(round(abs(current_Speed)*100))+" KM/H"

func move_train():
	STATE = speed_controller.value
	vectorDir = Vector2(0,0)
	if direction == "right":
		vectorDir = Vector2(1,0)
	if direction == "left":
		vectorDir = Vector2(-1,0)
	if direction == "up":
		vectorDir = Vector2(0,-1)
	if direction == "down":
		vectorDir = Vector2(0,1)
	
	if add_speed:
		position+=current_Speed*vectorDir


func _process(delta):
	# Smoothly interpolate towards the target rotation
	var rotation_speed = 8.0
	train_body.rotation = lerp_angle(train_body.rotation, new_rotation, rotation_speed * delta)
	
	
func clamp_speed_addon():
	#we clamp the speed with max
	if current_Speed>MAX_SPEED:
		current_Speed=current_Speed-ACC*STATE

func _physics_process(delta: float) -> void:
	#physics
	if STATE >= 0.1  and current_Speed<abs(STATE)*MAX_SPEED:
		current_Speed+=ACC*STATE
		
	if current_Speed>STOP_SPEED:
		#we need to decelerate => add speed backward
		current_Speed-=FRICTION*(1+(current_Speed*0.7))
	else:
		#we finally stop
		current_Speed=0
			
		
	update_ui()
	clamp_speed_addon()
	move_train()



func tourne(direction:String):
	if direction == "right":
		new_rotation = deg_to_rad(0)
		train_body.flip_h=true
		if smoke.position.x<0:
			smoke.position.x=-smoke.position.x
	if direction == "left":
		new_rotation = deg_to_rad(0)
		train_body.flip_h=false
		if smoke.position.x>0:
			smoke.position.x=-smoke.position.x
	if direction == "up":
		if smoke.position.x>0:
			smoke.position.x=-smoke.position.x
		if train_body.flip_h:
			train_body.flip_h=false
		new_rotation = deg_to_rad(90)
	if direction == "down":
		if smoke.position.x<0:
			smoke.position.x=-smoke.position.x
		if train_body.flip_h==false:
			train_body.flip_h=true
		new_rotation = deg_to_rad(90)
	_process(0)



func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("track"):
		var _continue := false
		if already_track == false:
			already_track = true
			last_track = area
			_continue = true
		else:
			if last_track !=area:
				last_track = area
				_continue = true
		if _continue:
			var _posx = area.global_position.x-position.x
			var _posy = area.global_position.y-position.y
			var ind =0
			if abs(_posx)>=abs(_posy):
				if area.get_parent().param_track.for_x[1] != direction and area.get_parent().param_track.for_x[1]!="":
					#we must inverse it because direction is the inverse of position : i go right, so i am left
					ind = 1
				if area.get_parent().param_track.for_y[ind] != "":
					direction = area.get_parent().param_track.for_y[ind]
					tourne(direction)
					position.x = area.global_position.x
			else:
				if area.get_parent().param_track.for_y[1] != direction and area.get_parent().param_track.for_y[1]!="":
					ind = 1
				if area.get_parent().param_track.for_x[ind] != "":
					direction = area.get_parent().param_track.for_x[ind]
					tourne(direction)
					position.y = area.global_position.y

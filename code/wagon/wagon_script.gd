extends CharacterBody2D

#improvement variables -----------------------------------------------------------------------------
var number_wagon := 2
const max_nb_passenger_per_wagon = 150


#Movement variables---------------------------------------------------------------------------------

#physics constants
var STOP_SPEED = 0.002

@export var ACC := 0.01
@export var FRICTION := 0.003
@export var max_dist : float = 75
@export var acc_dist : float = 60
@export var move_dist : float = 50

var current_Speed = 0
var direction = "left"

var STATE = 0.0 #0 no speed, >0 add speed, <0 decrease speed (between -1 and 1)

#main train ------------------------------------------------------------------------------------
@onready var train_main: CharacterBody2D = $"../train_main"
@onready var game: Node2D = $"../.."

#Turn variables----------------------------------------------------------------------------------
@onready var wagon_body: AnimatedSprite2D = $graphics
@onready var area_2d: Area2D = $AnimatedSprite2D/Area2D
@onready var speed_controller: VSlider = $"../../ui/right_down/VBoxContainer/speed_control/Control/speed_controller"
@onready var graphics: AnimatedSprite2D = $graphics

var train_forward

var last_track 
var already_track = false
var new_rotation = 0

var add_speed : bool = true
var can_add_speed : bool = true
var following : bool = true
var vectorDir : Vector2

var boost_speed : float = 1.0

#------------------------------------------------------------explosion var----------------------------------------------------
var is_exploding = false

var last_position : Vector2
var t := 0.0
var max_t = 1.0
var new_direction : Vector2
var last_wagon
var power = 200.0
var pos_2 
var pos_1
var speed
@onready var tree: Node2D = $"../.."

var apply_once = false
var timer_back = false
#--------------------------------------------------------------out of bounds var----------------------------------------------------
@onready var tracks: Node = $"../../track"
@export var max_dist_out_of_bound : float = 25.0
@onready var spark_part: CPUParticles2D = $rotate_point/grind

@onready var audio_manager: Node2D = $"../../AudioManager"
var audio_exp_once = false

func move_train():
	if following:
		current_Speed=train_forward.current_Speed
		STATE = speed_controller.value
	else:
		boost_speed=0.95
		current_Speed*=boost_speed
		STATE = 0
	vectorDir = Vector2(0,0)
	if direction == "right":
		vectorDir = Vector2(1,0)
	if direction == "left":
		vectorDir = Vector2(-1,0)
	if direction == "up":
		vectorDir = Vector2(0,-1)
	if direction == "down":
		vectorDir = Vector2(0,1)
	
	if add_speed and can_add_speed and train_forward != null and train_forward.current_Speed!=0:
		position+=current_Speed*boost_speed*vectorDir


func check_speed_in_turns():
	if train_main != null:
		if current_Speed>=train_main.MAX_SPEED*0.7:
			spark_part.emitting = true
		if current_Speed>=train_main.MAX_SPEED*0.9 and apply_once==false:
			spark_part.emitting = false
			#we boom
			vectorDir = Vector2(0,0)
			if direction == "right":
				vectorDir = Vector2(1,0)
			if direction == "left":
				vectorDir = Vector2(-1,0)
			if direction == "up":
				vectorDir = Vector2(0,-1)
			if direction == "down":
				vectorDir = Vector2(0,1)
				
			is_exploding=true
			apply_once=true
			Engine.time_scale=0.8
			speed=2.0
			power = 70.0
			last_position=position
			new_direction=vectorDir
			pos_2 = last_position+new_direction*power
			pos_1 = (pos_2+last_position)/2
			pos_1.y-=30.0
			hit_effect()

func check_for_out_of_track():
	var closest_track
	for track in tracks.get_children():
		if closest_track==null or sqrt((closest_track.position.x-position.x)**2+(closest_track.position.y-position.y)**2) > sqrt((track.position.x-position.x)**2+(track.position.y-position.y)**2) :
			closest_track=track
	if sqrt((closest_track.position.x-position.x)**2+(closest_track.position.x-position.x)**2)>max_dist_out_of_bound and apply_once==false:
		#dies
		vectorDir = Vector2(0,0)
		if direction == "right":
			vectorDir = Vector2(1,0)
		if direction == "left":
			vectorDir = Vector2(-1,0)
		if direction == "up":
			vectorDir = Vector2(0,-1)
		if direction == "down":
			vectorDir = Vector2(0,1)
			
		is_exploding=true
		apply_once=true
		Engine.time_scale=0.8
		speed=2.0
		power = 70.0
		last_position=position
		new_direction=vectorDir
		pos_2 = last_position+new_direction*power
		pos_1 = (pos_2+last_position)/2
		pos_1.y-=30.0
		hit_effect()
		
		
func loose_parent():
	var child_node = self
	child_node.get_parent().remove_child(child_node)
	game.add_child(child_node)

func hit_effect():
	#screen shake + time slowed down and bubble effect
	loose_parent()
	tree.apply_shake(position)
	
func small_tremble():
	#screen shake + time slowed down and bubble effect
	tree.apply_shake(position, 0.05)
	
	
func explosion():
	if audio_exp_once==false:
		audio_manager.explosion_a(position)
		audio_exp_once=true
	if timer_back:
		timer_back=false
		Engine.time_scale=1.0
	
	if speed>1.0:
		speed-=0.002
	else:
		timer_back=true
	var new_pos = bezier_curve(last_position,pos_1,pos_2, t*speed)
	get_child(1).rotation+=0.15
	position = new_pos

func _process(delta):
	if is_exploding==false:
		# Smoothly interpolate towards the target rotation
		var rotation_speed = 8.0
		wagon_body.rotation = lerp_angle(wagon_body.rotation, new_rotation, rotation_speed * delta)
		var to_add = 0
		if wagon_body.flip_h==true:
			spark_part.get_parent().scale.x=-1
		else:
			spark_part.get_parent().scale.x=1
		
		spark_part.get_parent().rotation = lerp_angle(spark_part.get_parent().rotation, new_rotation, rotation_speed * delta)

func dist(a,b):
	return sqrt((a.x-b.x)**2+(a.y-b.y)**2)
	

func _physics_process(delta: float) -> void:
	if train_main != null:
		if current_Speed<train_main.MAX_SPEED*0.7:
			spark_part.emitting = false
		if current_Speed>train_main.MAX_SPEED*0.9:
			small_tremble()
	if is_exploding==false:
		check_for_out_of_track()
		#check for stop
		if train_forward != null:
			if dist(train_forward.position,position)>max_dist:
				following=false
				loose_parent()
			if dist(train_forward.position,position)>acc_dist:
				boost_speed=1.2
			if dist(train_forward.position,position)<move_dist and train_forward.vectorDir == vectorDir:
				can_add_speed=false
			elif dist(train_forward.position,position)>30:
				can_add_speed=true
		else:
			loose_parent()
			following=false
		
		#input check
		if STATE >= 0.1 and current_Speed<abs(STATE)*2:
			current_Speed+=ACC*STATE
		
		#physics
		if current_Speed>STOP_SPEED:
			#we need to decelerate => add speed backward
			current_Speed-=FRICTION*(1+(current_Speed*0.7))
		else:
			#we finally stop
			current_Speed=0
			
		move_train()
	else:
		t+=delta*0.5
		explosion()
		if t>=max_t:
			tree.apply_shake(position)
			tree.last_explosion_effect(position)
			queue_free()
		#rotate the train while in the air / add speed opposite to collision impact => boom vfx

func tourne(direction:String):
	if direction == "right":
		new_rotation = deg_to_rad(0)
		wagon_body.flip_h=true
	if direction == "left":
		new_rotation = deg_to_rad(0)
		wagon_body.flip_h=false
	if direction == "up":
		if wagon_body.flip_h:
			wagon_body.flip_h=false
		new_rotation = deg_to_rad(90)
	if direction == "down":
		if wagon_body.flip_h==false:
			wagon_body.flip_h=true
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
			var s_dir = direction
			if s_dir == "left":
				s_dir="right"
			elif s_dir == "right":
				s_dir="left"
			elif s_dir == "down":
				s_dir="up"
			elif s_dir == "up":
				s_dir="down"
			var y=0
			if s_dir in area.get_parent().param_track.for_x:
				if s_dir == area.get_parent().param_track.for_x[0]:
					y=0
				else:
					y=1
				if area.get_parent().param_track.for_y[y] != "":
					direction = area.get_parent().param_track.for_y[y]
					check_speed_in_turns()
					tourne(direction)
					position.x = area.global_position.x
			elif s_dir in area.get_parent().param_track.for_y:
				if s_dir == area.get_parent().param_track.for_y[0]:
					y=0
				else:
					y=1
				if area.get_parent().param_track.for_x[y] != "":
					direction = area.get_parent().param_track.for_x[y]
					check_speed_in_turns()
					tourne(direction)
					position.y = area.global_position.y

func bezier_curve(v1,v2,v3,_t):
	return (1-_t)**2*v1+2*(1-_t)*_t*v2+_t**2*v3

func _on_collision_area_entered(area: Area2D) -> void:
	if area.is_in_group("wagon") and apply_once==false:
		apply_once=true
		if abs(area.get_parent().position.x-position.x) > abs(area.get_parent().position.y-position.y):
			new_direction = -Vector2(area.get_parent().position.x-position.x,area.get_parent().position.y-position.y+float(randi_range(-20,20))).normalized()
		else:
			new_direction = -Vector2(area.get_parent().position.x-position.x+float(randi_range(-10,5)),area.get_parent().position.y-position.y).normalized()
			
		Engine.time_scale=0.8
		speed=2.0
		power = 110.0
		last_position=position
		pos_2 = last_position+new_direction*power
		pos_1 = (pos_2+last_position)/2
		pos_1.y-=30.0
		is_exploding=true
		last_wagon = area.get_parent()
		hit_effect()

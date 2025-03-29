extends CharacterBody2D

#improvement variables -----------------------------------------------------------------------------
var number_wagon := 0
@export var lives = 2

#management var -----------------------------------------------------------------------------------
@export var list_wagon : Array[CharacterBody2D]
#Movement variables---------------------------------------------------------------------------------

#physics constants
var MAX_SPEED = 2.0
var STOP_SPEED = 0.002

var ACC := 0.01
var FRICTION := 0.003

@export var current_Speed = 0
var direction = "left"

var STATE = 0.0 #0 no speed, >0 add speed, <0 decrease speed (between -1 and 1)

#Turn variables----------------------------------------------------------------------------------
@onready var train_body: AnimatedSprite2D = $graphics
@onready var area_2d: Area2D = $AnimatedSprite2D/Area2D

var last_track 
var already_track = false
var new_rotation = 0

#money var --------------------------------------------------------------------------------------
var money = 100
var price_per_coal = 6
var price_per_people = 2
@onready var money_ui: Label = $"../../ui/right_top/Container/PanelContainer/money_text"

#passengers var----------------------------------------------------------------------------------
@export var wait_time_stopped := 1.0  #controls the time that the train is going to spend on each station
@onready var train_part: Node = $".."

var passengers = 0
var dict_people = {}

const max_nb_passenger_per_wagon = 70
@onready var MANAGER: Node2D = $"../.."
#coal var ---------------------------------------------------------------------------------------
@export var coal_level := 13.0
@export var max_level_coal := 13.0
@export var percentage_less := 0.005

@onready var fire: CPUParticles2D = $"../../ui/left_down/fire"
@onready var fire_2: CPUParticles2D = $"../../ui/left_down/fire2"
@onready var fire_3: CPUParticles2D = $"../../ui/left_down/fire3"
@onready var s_smoke_1: CPUParticles2D = $"../../ui/left_down/smoke_1"
@onready var s_smoke_2: CPUParticles2D = $"../../ui/left_down/smoke_2"
@onready var s_smoke_3: CPUParticles2D = $"../../ui/left_down/smoke_3"


@onready var coal_ui: AnimatedSprite2D = $"../../ui/left_down/coal"

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
@onready var smoke_2: CPUParticles2D = $graphics/smoke/smoke
@onready var smoke_3: CPUParticles2D = $graphics/smoke/smoke2

@export var change_values = [0.6,0.9]
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
var last_wagon_hit = null
#--------------------------------------------------------------out of bounds var----------------------------------------------------
@onready var tracks: Node = $"../../track"
@export var max_dist_out_of_bound : float = 25.0
@onready var spark_part: CPUParticles2D = $rotate_point/grind

@onready var audio_manager: Node2D = $"../../AudioManager"
var audio_exp_once = false
var audio_horn_once = false


func fly_away(n_direction = null):
	apply_once=true
	var dir
	if n_direction==null:
		dir = new_direction
	else:
		dir = n_direction
	Engine.time_scale=0.8
	speed=2.0
	power = 110.0
	last_position=position
	pos_2 = last_position+dir*power
	pos_1 = (pos_2+last_position)/2
	pos_1.y-=30.0
	is_exploding=true
	hit_effect()

func check_speed_in_turns():
	if current_Speed>=MAX_SPEED*0.7:
		spark_part.emitting = true
	if current_Speed>=MAX_SPEED*0.9 and apply_once==false:
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
	if sqrt((closest_track.position.x-position.x)**2+(closest_track.position.x-position.x)**2)>max_dist_out_of_bound:
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
		lives=0
		hit_effect()
		

func hit_effect():
	#screen shake + time slowed down and bubble effect
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




func update_coal():
	coal_level -= (((current_Speed-0.15)**2)/(current_Speed*0.85+0.8)+0.2)*percentage_less
	if coal_level>=5:
		audio_horn_once=false
		
	if coal_level<4:
		if audio_horn_once==false:
			audio_manager.train_horn_a(position)
			audio_horn_once=true

func _ready():
	start_scale = side_select.scale
	var vect = Vector2(Vector2(selector.position.x-70,selector.position.y-7)-side_select.position)
	start_dist = sqrt(vect.x**2+vect.y**2)

func update_ui():
	number_wagon=train_part.get_child_count()
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
	#update coal
	var coal_frame =int(max_level_coal-coal_level)
	coal_ui.frame=coal_frame
	if current_Speed>=change_values[0]*MAX_SPEED:
		fire_2.emitting = true
		s_smoke_1.emitting = true
	else:
		fire_2.emitting = false
		s_smoke_1.emitting = false
	if current_Speed>=change_values[1]*MAX_SPEED:
		fire_3.emitting = true
		s_smoke_2.emitting = true
		s_smoke_3.emitting = true
	else:
		fire_3.emitting = false
		s_smoke_2.emitting = false
		s_smoke_3.emitting = false
	
	#update money
	money_ui.text = str(int(money))
	
	#update passengers
	passenger_ui.text = "     "+str(passengers)+"/"+str(max_nb_passenger_per_wagon*number_wagon)
	
	
	#update speed
	var last_speed = float(speed_ui.text.split(" ")[0])
	if abs(last_speed-(abs(current_Speed)*100))>=1.0:
		speed_ui.text=str(round(abs(current_Speed)*100))+" KM/H"

func move_train():
	if coal_level>0:
		STATE = speed_controller.value
		smoke.emitting = true
		fire.emitting = true
	else:
		smoke.emitting = false
		fire.emitting = false
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
	
	if add_speed:
		audio_manager.train_running_a(current_Speed/MAX_SPEED)
		position+=current_Speed*vectorDir


func _process(delta):
	# Smoothly interpolate towards the target rotation
	var rotation_speed = 8.0
	train_body.rotation = lerp_angle(train_body.rotation, new_rotation, rotation_speed * delta)
	if lives<=0 and apply_once==false:
		apply_once=true
		fly_away()
	
func change_smoke():
	#2nd smoke effect
	if change_values[0]*MAX_SPEED<=abs(current_Speed):
		smoke_2.emitting = true
	else:
		smoke_2.emitting = false
	
	#3rd smoke effect
	if change_values[1]*MAX_SPEED<=abs(current_Speed):
		smoke_3.emitting = true
	else:
		smoke_3.emitting = false
	
func clamp_speed_addon():
	#we clamp the speed with max
	if current_Speed>MAX_SPEED:
		current_Speed=current_Speed-ACC*STATE

func _physics_process(delta: float) -> void:
	if current_Speed<MAX_SPEED*0.7:
		spark_part.emitting = false
	if current_Speed>MAX_SPEED*0.9:
		audio_manager.train_brakes(position)
		small_tremble()
	if is_exploding==false:
		check_for_out_of_track()
		#physics
		if STATE >= 0.1  and current_Speed<abs(STATE)*MAX_SPEED:
			current_Speed+=ACC*STATE
			
		if current_Speed>STOP_SPEED:
			#we need to decelerate => add speed backward
			current_Speed-=FRICTION*(1+(current_Speed*0.7))
		else:
			#we finally stop
			current_Speed=0
			
		#game logic
		if money < 0:
			loose()
		
		update_ui()
		clamp_speed_addon()
		move_train()
		change_smoke()
		update_coal()
	else:
		t+=delta*0.5
		explosion()
		if t>=max_t:
			tree.apply_shake(position)
			tree.last_explosion_effect(position)
			tree.lost()
			queue_free()
			
		#rotate the train while in the air / add speed opposite to collision impact => boom vfx

func loose():
	MANAGER.lost()
	#tree.lost()


func tourne(direction:String):
	if direction == "right":
		new_rotation = deg_to_rad(0)
		train_body.flip_h=true
		if smoke.position.x<0:
			smoke.position.x=-smoke.position.x
			smoke_2.position.x=-smoke_2.position.x
	if direction == "left":
		new_rotation = deg_to_rad(0)
		train_body.flip_h=false
		if smoke.position.x>0:
			smoke.position.x=-smoke.position.x
			smoke_2.position.x=-smoke_2.position.x
	if direction == "up":
		if train_body.flip_h:
			train_body.flip_h=false
		new_rotation = deg_to_rad(90)
	if direction == "down":
		if train_body.flip_h==false:
			train_body.flip_h=true
		new_rotation = deg_to_rad(90)
	_process(0)

func start_stop():
	audio_manager.train_brakes(position)
	#used when entering a station and when you need to slow down
	slow_down()

func slow_down():
	#will call itself to slow down
	await get_tree().create_timer(0.1).timeout
	if current_Speed >= 0:
		current_Speed -= ACC*25
	if current_Speed < 0:
		add_speed = false
		await get_tree().create_timer(wait_time_stopped).timeout
		add_speed = true
	else:
		slow_down()


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
					check_speed_in_turns()
					tourne(direction)
					position.x = area.global_position.x
			else:
				if area.get_parent().param_track.for_y[1] != direction and area.get_parent().param_track.for_y[1]!="":
					ind = 1
				if area.get_parent().param_track.for_x[ind] != "":
					direction = area.get_parent().param_track.for_x[ind]
					check_speed_in_turns()
					tourne(direction)
					position.y = area.global_position.y
					
	if area.is_in_group("station"):
		var obj_parent = area.get_parent().get_parent()
		if obj_parent not in dict_people:
			dict_people[obj_parent] = 0
		if obj_parent.current_pers != 0 or dict_people[obj_parent]!=0:
			start_stop() 
			obj_parent.level+=1
			if obj_parent in dict_people:
				var nb_people_down = dict_people[obj_parent]
				dict_people[obj_parent] = 0
				money+=nb_people_down*price_per_people
				passengers -= nb_people_down
				MANAGER.exp_up(nb_people_down)
		if obj_parent.current_pers != 0:
			if passengers+obj_parent.current_pers<=max_nb_passenger_per_wagon*number_wagon:
				passengers+=obj_parent.current_pers
				var people = obj_parent.person_destination
				for key in people:
					if key in dict_people:
						dict_people[key] += people[key] #we add them to our number
					else:
						dict_people[key] = people[key] #we add them to our number
					
				obj_parent.current_pers = 0
			else:
				var pass_to_add = max_nb_passenger_per_wagon*number_wagon-passengers
				passengers+=pass_to_add
				
				var people = obj_parent.person_destination
				var nb_people = pass_to_add
				for key in people:
					if key in dict_people:
						for passenger in people[key]:
							if nb_people>0:
								dict_people[key] += passenger #we add them to our number one by one :skull: rip optimisation
					else:
						if nb_people>0:
							dict_people[key] = 0 #initialisation
						for passenger in people[key]:
							if nb_people>0:
								nb_people-=1
								dict_people[key] += 1 #we add them to our number one by one :skull: rip optimisation
				
				obj_parent.current_pers -=pass_to_add
			
	if area.is_in_group("coal_station"):
		if coal_level<=max_level_coal-1:
			start_stop() 
			var nb_coal = int(max_level_coal)-int(coal_level)
			coal_level = max_level_coal
			money -= nb_coal*price_per_coal

func bezier_curve(v1,v2,v3,_t):
	return (1-_t)**2*v1+2*(1-_t)*_t*v2+_t**2*v3

func _on_collision_area_entered(area: Area2D) -> void:
	if area.is_in_group("wagon") and last_wagon_hit!=area.get_parent():
		last_wagon_hit=area.get_parent()
		if abs(area.get_parent().position.x-position.x) > abs(area.get_parent().position.y-position.y):
			new_direction = -Vector2(area.get_parent().position.x-position.x,area.get_parent().position.y-position.y+float(randi_range(-20,20))).normalized()
		else:
			new_direction = -Vector2(area.get_parent().position.x-position.x+float(randi_range(-10,5)),area.get_parent().position.y-position.y).normalized()
		last_wagon = area.get_parent()
		lives-=1

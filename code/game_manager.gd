extends Node2D
#station management -------------------------------------------------------------------------------
var list_stations : Array[StaticBody2D]
@onready var stations: Node2D = $stations


@export var DIFF_LEVEL = 0
var exp : float = 0.0

@export var MAX_DIST_STATIONS = 400
@export var MIN_DIST_BTW_EVERYTHING = 70
@export var AVG_TIME_BTW_SPAWNS = 90
@export var TIME_DIST = 20

@export var CHANCES_SPAWN : Array[float]

@export var list_levels : Array[int]

#2 first time, 2 next people
@export var list_small_stations : Array[int]
@export var list_mid_stations : Array[int]
@export var list_big_stations : Array[int]

@export var scale_small : Vector2 
@export var scale_mid : Vector2 
@export var scale_big : Vector2 

@onready var track: Node = $track
@onready var station: Node2D = $stations

@onready var tile_map_w: TileMapLayer = $water
@onready var tile_map_t: TileMapLayer = $tree

var list_tile_water = []
var list_tile_tree = []

var const_obj
var station_obj

var has_spawned = true
#-----------------------------------------------------------sceen shake------------------------------------------------------------
@onready var cam: Camera2D = $Camera2D

@export var randomStrength: float = 10.0
@export var shakeFade: float = 5.0

var rng = RandomNumberGenerator.new()
var shake_strength : float = 0.0
#--------------------------------------------------------------link to all effects-------------------------------------------------
var EXPLOSION
var SHADER_EXPLOSION
@onready var instantiate_place: StaticBody2D = $stations/c_station
@onready var shaders: Node2D = $shaders
@onready var timer: Label = $ui/middle_up/timer
var timer_time = 0
@onready var button_quit: Button = $QUIT_BUTTON/Button
@onready var audio_manager: Node2D = $AudioManager

#------------------------------------------------------------------loose screen---------------------------------
@onready var score: Label = $ui/end_screen/Panel/hs
@onready var end_screen: Control = $ui/end_screen
@onready var quit_panel: Sprite2D = $ui/end_screen/Panel/QUIT_BUTTON/QuitPanel
@onready var button: Button = $ui/end_screen/Panel/QUIT_BUTTON/Button

var current_score = 0
var loose = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EXPLOSION = preload("res://scene/effects/explosion.tscn")
	SHADER_EXPLOSION = preload("res://scene/effects/shader_explosion.tscn")
	const_obj = preload("res://scene/stations/const_station.tscn")
	station_obj = preload("res://scene/stations/station.tscn")
	manage_list_stations()
	manage_list_water()
	manage_list_tree()
	
	button_quit.button_down.connect(menu)
	button.button_down.connect(menu)

func menu():
	get_tree().change_scene_to_file("res://scene/menu/main_menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_score+=delta
	if timer_time>0:
		timer_time-=delta
		timer.text = str(roundi(timer_time))
	else:
		timer.text = str(0)
	
	disable_shaders()
	
	move_cam(delta)
	if has_spawned:
		has_spawned=false
		wait_for_const()


func disable_shaders():
	if VarSaver.hasShaders==false and shaders.visible == true:
		shaders.visible = false 
	if VarSaver.hasShaders==true and shaders.visible == false:
		shaders.visible = true 

func exp_up(nb_pers):
	exp+=float(nb_pers)
	if exp >= 30 * (1+DIFF_LEVEL*0.2):
		exp=0.0
		DIFF_LEVEL+=1
		
func manage_list_tree():
	var list = []
	for cell in tile_map_t.get_used_cells():
		list.append(Vector2(cell.x*64+32,cell.y*64+32))
	list_tile_tree = list
	
func manage_list_water():
	var list = []
	for cell in tile_map_w.get_used_cells():
		list.append(Vector2(cell.x*64+32,cell.y*64+32))
	list_tile_water = list

func manage_list_stations():
	var temp_l: Array[StaticBody2D]=[]
	for elt in stations.get_children():
		if elt.get_script() != null: #get rid of coal station
			temp_l.append(elt)
	list_stations=temp_l
	
func lower_spawn_rate():
	CHANCES_SPAWN[0]*=0.99
	CHANCES_SPAWN[1]*=0.995
	
#creation of new stations
func wait_for_const():
	var rd_time = randi_range(0,30)
	timer_time = AVG_TIME_BTW_SPAWNS+rd_time
	await get_tree().create_timer(AVG_TIME_BTW_SPAWNS+rd_time).timeout 
	create_station()

func create_station():
	#the difficulty goes up, from small cities (long time between spawns) to bigger ones faster
	#the small cities will be in the furthest range (which will get bigger over time)
	#the big cities will be in mid range and far from each others
	#cities will take 30 secs to build themselves
	#cities will avoid already existing tracks (min dist) and each others
	
	#city selection and range
	var city_chance=randf_range(0,1)
	var city_type="small"
	var city_range = 100
	if city_chance < CHANCES_SPAWN[0]:
		#small city
		city_type="small"
		city_range = (MAX_DIST_STATIONS*(randf_range(0.1+DIFF_LEVEL/80,0.2+DIFF_LEVEL/80)))
	elif city_chance < CHANCES_SPAWN[0]+CHANCES_SPAWN[1]:
		#mid city
		city_type="mid"
		city_range = ((MAX_DIST_STATIONS-100)*(randf_range(0.07+DIFF_LEVEL/80,0.22+DIFF_LEVEL/80)))
	else:
		#big city
		city_type="big"
		city_range = ((MAX_DIST_STATIONS-200)*(randf_range(0.05+DIFF_LEVEL/80,0.31+DIFF_LEVEL/80)))
	var city_pos : Vector2 = pseudo_random_pos(city_range)
	var x_pos = int(city_pos.x)%25
	if x_pos>12:
		city_pos.x+= 25-x_pos
	else:
		city_pos.x-=x_pos
	var y_pos = int(city_pos.y)%25
	if y_pos>12:
		city_pos.y+= 25-y_pos
	else:
		city_pos.y-=y_pos
	lower_spawn_rate()
	start_building("small", city_pos)

func start_building(type, pos):
	audio_manager.station_building_a(pos)
	var const_instance = const_obj.instantiate()
	const_instance.position = pos
	add_child(const_instance)
	await get_tree().create_timer(2).timeout 
	const_instance.play("idle")
	await get_tree().create_timer(26).timeout #we wait 30 secs for the creation
	
	#we can add the station
	var station_instance = station_obj.instantiate()
	station_instance.position = pos
	station.add_child(station_instance)
	
	if type == "small":
		pass
	if type == "mid":
		station_instance.level = 7
	if type == "big":
		station_instance.level = 18
		
	const_instance.play("deconstruction")
	await get_tree().create_timer(1).timeout #we wait 30 secs for the creation
	audio_manager.stop_building_a()
	manage_list_stations()
	const_instance.queue_free()
	has_spawned = true


func pseudo_random_pos(range, base_angle = -1, new_angle = -1, i=0):
	#crazy calculus comming up... better close your eyes
	var rd_angle = new_angle
	if new_angle < 0:
		if base_angle<0:
			rd_angle = randi_range(-180,180)
		else:
			rd_angle=base_angle
	var z_pos_x = range*cos(deg_to_rad(rd_angle))
	var z_pos_y = range*sin(deg_to_rad(rd_angle))
	var pos : Vector2 = Vector2(z_pos_x,z_pos_y)
	#we check we aren't too close to other structures
	var list_to_avoid = station.get_children()
	list_to_avoid.append_array(track.get_children())
	var is_good = true
	for elt in list_to_avoid:
		if sqrt((elt.position.x-pos.x)**2+(elt.position.y-pos.y)**2)<MIN_DIST_BTW_EVERYTHING:
			is_good = false
	if is_good == true:
		for tile in list_tile_water:
			if sqrt((tile[0]-pos.x)**2+(tile[1]-pos.y)**2)<MIN_DIST_BTW_EVERYTHING:
				is_good = false
	if is_good == true:
		for tile in list_tile_tree:
			if sqrt((tile[0]-pos.x)**2+(tile[1]-pos.y)**2)<MIN_DIST_BTW_EVERYTHING:
				is_good = false
	
	if is_good == false:
		if i>=35:
			pos = pseudo_random_pos(range+8, base_angle,-1,i+1)
		else:
			if base_angle<0:
				base_angle=rd_angle
			if new_angle<0:
				new_angle=rd_angle
			pos = pseudo_random_pos(range, base_angle, new_angle+10,i+1)
	return pos

func lost():
	loose = true
	if score.text == "":
		score.text = str(int(current_score))
	end_screen.visible = true
	quit_panel.visible = true
	button.visible = true
	Engine.time_scale=0.00001

func screen_size():
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_zoom = cam.zoom

	var in_game_size = viewport_size / camera_zoom
	return in_game_size

func apply_shake(pos, str = null):
	var screen_s = screen_size()
	if str == null:
		shake_strength+=randomStrength
		
		var distortion_explode = SHADER_EXPLOSION.instantiate()
		instantiate_place.add_child(distortion_explode)
		distortion_explode.material.set_shader_parameter("center", Vector2(0.5+((pos.x-cam.position.x)/(screen_s.x)),0.5+((pos.y-cam.position.y)/(screen_s.y))))
		var explosion_anim = distortion_explode.get_child(0)
		explosion_anim.play("shockwave")
	else:
		shake_strength+=str

func last_explosion_effect(pos):
	audio_manager.explosion_a(pos)
	var explosion_vfx = EXPLOSION.instantiate()
	add_child(explosion_vfx)
	explosion_vfx.position=pos
	explosion_vfx.emitting=true
	explosion_vfx.get_child(0).emitting=true
	explosion_vfx.get_child(0).get_child(0).emitting=true

func random_offset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength,shake_strength))
	
func move_cam(delta):
	if loose == false:
		if shake_strength>0:
			shake_strength = lerpf(shake_strength,0,shakeFade*delta)
			cam.offset = random_offset()

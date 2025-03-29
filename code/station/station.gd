extends StaticBody2D
var min_time = 10.0
var max_time = 20.0
var min_pers = 8
var max_pers = 20

@export var normal_scale : Vector2 = Vector2(1,1)
@export var close_scale : Vector2 = Vector2(0,0)
@export var anim_time : float = 1.2
@export var transition_type : Tween.TransitionType

var current_pers = 0
var current_time = 0
@export var level = 1
var type = "small"

@onready var our_station: StaticBody2D = $"."
@onready var graphics: AnimatedSprite2D = $Scale/graphics


@onready var MANAGER: Node2D = $"../.."
@onready var train: CharacterBody2D = $"../../train_part/train_main"
@onready var panel: Panel = $Control/Panel

@onready var pers_ui: Label = $Control/Panel/VBoxContainer/pers
@onready var time_ui: Label = $Control/Panel/VBoxContainer/time

var ui_scale_up : Vector2 = Vector2(1,1.4)
var ui_scale_down : Vector2 = Vector2(1,0.6)

var do_once : bool = false
var do_once_ui : bool = false

var person_destination = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_stats()
	call_deferred("set_up")

func set_up():
	time_ui.pivot_offset = time_ui.size/2

func set_stats():
	if type == "small":
		graphics.animation = "small"
		graphics.get_parent().scale = MANAGER.scale_small
		min_time = MANAGER.list_small_stations[0]
		max_time = MANAGER.list_small_stations[1]
		min_pers = MANAGER.list_small_stations[2]
		max_pers = MANAGER.list_small_stations[3]
	if type == "mid":
		graphics.animation = "mid"
		graphics.get_parent().scale = MANAGER.scale_mid
		min_time = MANAGER.list_mid_stations[0]
		max_time = MANAGER.list_mid_stations[1]
		min_pers = MANAGER.list_mid_stations[2]
		max_pers = MANAGER.list_mid_stations[3]
	if type == "big":
		graphics.animation = "big"
		graphics.get_parent().scale = MANAGER.scale_big
		min_time = MANAGER.list_big_stations[0]
		max_time = MANAGER.list_big_stations[1]
		min_pers = MANAGER.list_big_stations[2]
		max_pers = MANAGER.list_big_stations[3]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#level part
	if level == MANAGER.list_levels[0]:
		type = "mid"
		#change the sprite and whole stats
		set_stats()
		level+=1
	if level == MANAGER.list_levels[1]:
		type = "big"
		#change the sprite and stats
		set_stats()
		level+=1
	#time part
	if current_pers==0 and do_once==false:
		do_once = true
		add_tween(panel,"scale", close_scale, anim_time)
		wait_panel(3.0)
	else:
		if current_time >= 0:
			current_time-=delta
			update_ui()
		else:
			#perdu de la thune
			if train != null:
				train.money-=current_pers*train.start_price_per_people
			current_pers=0

func update_ui():
	if current_time<=5.0 and do_once_ui == false:
		do_once_ui=true
		anim_ui_text()
	pers_ui.text=str(current_pers)
	time_ui.text=str(round(current_time))
	if current_time<=0:
		time_ui.text="0"

func start_show_ui():
	add_tween(panel,"scale", normal_scale, anim_time)
	do_once = false

func anim_ui_text():
	add_tween(time_ui,"scale", ui_scale_down, 0.7)
	wait_ui(0.7)

func anim_ui_up():
	add_tween(time_ui,"scale", ui_scale_up, 0.7)
	wait_ui_back(0.7)

func wait_panel(seconds: float):
	await get_tree().create_timer(seconds).timeout
	start_show_ui()
	current_pers = randi_range(min_pers+int(level/2),max_pers+int(level/2))
	current_time = randi_range(min_time-int(level/8),max_time-int(level/5))
	person_destination = select_people()

func select_people():
	var list_stations = select_stations()
	var total_power = 0
	for elt in list_stations:
		total_power+=elt[1]
	var new_dict = {}
	var nb_pers = current_pers #so that we don't have rounding issues (one pers missing...)
	for i in range(len(list_stations)):
		if i == len(list_stations)-1:
			new_dict[list_stations[i][0]] = nb_pers
		else:
			new_dict[list_stations[i][0]] = int((list_stations[i][1]/total_power)*current_pers)
			nb_pers -= int((list_stations[i][1]/total_power)*current_pers)
	return new_dict

func select_stations():
	#get rid of ourselves:
	var list = []
	for elt in MANAGER.list_stations:
		if elt != our_station:
			list.append(elt)
	
	var dict_stations = {}
	for i in range(len(list)):
		var divide = 0
		if type == "small":
			divide = 12
		if type == "mid":
			divide = 6
		if type == "big":
			divide = 2
		var part : float =(float(list[i].level)/float(divide))
		dict_stations[list[i]] = part*randf_range(0.2,2.5)
	
	var list_n_stations = []
	if type == "small":
		for i in range(randi_range(3,4)):
			if len(list) != 0:
				var ind=list[0]
				for y in list:
					if dict_stations[y]>dict_stations[ind]:
						ind=y
				list_n_stations.append([ind,dict_stations[ind]])
				dict_stations.erase(ind)
				var temp_l = []
				for elt in list:
					if elt != ind:
						temp_l.append(elt)
				list = temp_l
	if type == "mid":
		for i in range(randi_range(2,3)):
			if len(list) != 0:
				var ind=list[0]
				for y in list:
					if dict_stations[y]>dict_stations[ind]:
						ind=y
				list_n_stations.append([ind,dict_stations[ind]])
				dict_stations.erase(ind)
				var temp_l = []
				for elt in list:
					if elt != ind:
						temp_l.append(elt)
				list = temp_l
	if type == "big":
		for i in range(randi_range(1,3)):
			if len(list) != 0:
				var ind=list[0]
				for y in list:
					if y in dict_stations and ind in dict_stations and dict_stations[y]>dict_stations[ind]:
						ind=y
				list_n_stations.append([ind,dict_stations[ind]])
				dict_stations.erase(ind)
				var temp_l = []
				for elt in list:
					if elt != ind:
						temp_l.append(elt)
				list = temp_l
	return list_n_stations # (station, station attractiveness)

func wait_ui_back(seconds: float):
	await get_tree().create_timer(seconds).timeout
	do_once_ui=false
	
func wait_ui(seconds: float):
	await get_tree().create_timer(seconds).timeout
	anim_ui_up()

func add_tween(element,property:String,value, seconds:float):
	var tween = get_tree().create_tween()
	tween.tween_property(element, property, value, seconds).set_trans(transition_type)

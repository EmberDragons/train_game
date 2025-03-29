extends Node

@onready var game: Node2D = $".."
@onready var selector: Control = $"../ui/middle_down/selector"
@onready var button_up: Node2D = $"../ui/middle_down/Button_up"
@onready var button_down: Node2D = $"../ui/middle_down/Button_down"

@onready var selector_game: AnimatedSprite2D = $"../selector"
@onready var train_main: CharacterBody2D = $"../train_part/train_main"
@onready var train_part: Node = $"../train_part"


var track_list = [preload("res://scene/tracks/vertical_forward.tscn"), preload("res://scene/tracks/left_up.tscn"),
						preload("res://scene/tracks/left_down.tscn"), preload("res://scene/tracks/right_up.tscn"),
						preload("res://scene/tracks/right_down.tscn"), preload("res://scene/tracks/horizontal_forward.tscn"),
						preload("res://scene/tracks/U_up.tscn"), preload("res://scene/tracks/U_right.tscn"),
						preload("res://scene/tracks/U_down.tscn"), preload("res://scene/tracks/U_left.tscn")]
var wagon_list = [preload("res://scene/train/wagon_coal.tscn"),preload("res://scene/train/wagon_hay.tscn"),
				preload("res://scene/train/wagon_people.tscn"),preload("res://scene/train/wagon_people_2.tscn"),
				preload("res://scene/train/wagon_small_coal.tscn"),preload("res://scene/train/wagon_wood.tscn"),]
var grid_Size = 25
var dict_tracks = {}

var is_placing : bool = false
var can_place : bool = true
var mouse_pos : Vector2

var selected_button : Button = null
var index : int = 0

var banned_nodes = []

#--------------------------------------------------------------link to all effects-------------------------------------------------
const PLACE_EFFECT = preload("res://scene/effects/place_effect.tscn")
@onready var audio_manager: Node2D = $"../AudioManager"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_set_up()
	dict_set_up()

func button_set_up():
	for i in range(len(button_up.get_children())):
		button_up.get_child(i).button_down.connect(button_up_pressed.bind(i))
	
	for y in range(len(button_down.get_children())):
		button_down.get_child(y).button_down.connect(button_down_pressed.bind(y))

func button_up_pressed(i):
	audio_manager.tab_a()
	#we set all butons to visible = false
	selected_button = null
	selector.visible = false
	for button in button_down.get_children():
		button.visible = false

	var length = 5 #there are 5 buttons
	var start = i*5
	for y in range(start,start+length):
		if y<button_down.get_child_count():
			button_down.get_child(y).visible = true

func button_down_pressed(i):
	audio_manager.select_a()
	if button_down.get_child(i).action == 'track':
		if selected_button == null:
			index=i
			is_placing = true
			selector_game.visible = true
			selected_button=button_down.get_child(i)
			selector.position=selected_button.position
			selector.visible = true
		elif selected_button != button_down.get_child(i):
			index=i
			is_placing = true
			selector_game.visible = true
			selected_button=button_down.get_child(i)
			selector.position=selected_button.position
		else:
			is_placing = false
			selector_game.visible = false
			selected_button = null
			selector.visible = false
	if button_down.get_child(i).action == 'add_wagon':
		var boolean = add_wagon()
		if boolean == true:
			train_main.money -= int(button_down.get_child(i).get_child(2).text)
		selector.visible = true
		selector.position=button_down.get_child(i).position
		await get_tree().create_timer(0.1).timeout 
		selector.visible = false
	if button_down.get_child(i).action == 'add_speed':
		add_speed()
		train_main.money -= int(button_down.get_child(i).get_child(2).text)
		selector.visible = true
		selector.position=button_down.get_child(i).position
		await get_tree().create_timer(0.1).timeout 
		selector.visible = false
	if button_down.get_child(i).action == 'add_coal':
		add_coal()
		train_main.money -= int(button_down.get_child(i).get_child(2).text)
		selector.visible = true
		selector.position=button_down.get_child(i).position
		await get_tree().create_timer(0.1).timeout 
		selector.visible = false
	if button_down.get_child(i).action == 'add_money':
		add_money()
		train_main.money -= int(button_down.get_child(i).get_child(2).text)
		selector.visible = true
		selector.position=button_down.get_child(i).position
		await get_tree().create_timer(0.1).timeout 
		selector.visible = false
		
func add_money():
	train_main.price_per_people*=1.20
func add_coal():
	train_main.percentage_less*=0.92
func add_speed():
	train_main.ACC*=1.08
	train_main.MAX_SPEED*=1.08
	
func add_wagon():
	var last_train = train_part.get_child(-1)
	var pos = Vector2(int(train_part.get_child(-1).position.x/25),int(train_part.get_child(-1).position.y/25))
	#1 : we determine the direction
	#2 : we skip the nodes that are in the direction we are going
	#3 : we check all nodes connected to them and wheter they can turn this way 
	# done
	banned_nodes=[]
	var possible_nodes = []
	var liste_first_nodes = check_close_nodes(pos, last_train.direction)
	for node in liste_first_nodes:
		var new_pos = Vector2(int(node[0].position.x/25),int(node[0].position.y/25))
		var new_dir = pos-new_pos
		var vectorDir = "left"
		if new_dir == Vector2(1,0):
			vectorDir = "right"
		elif new_dir == Vector2(0,-1):
			vectorDir = "up"
		elif new_dir == Vector2(0,1):
			vectorDir = "down"
		var new_nodes = check_close_nodes(new_pos, last_train.direction)
		for new_node in new_nodes:
			if new_node[0] not in banned_nodes and new_node[0].position/25 != pos:
				possible_nodes.append(new_node)
	if possible_nodes == []:
		return false
	var id = randi_range(0,len(wagon_list)-1)
	var instance = wagon_list[id].instantiate()
	instance.direction = possible_nodes[0][1]
	instance.train_forward = last_train
	train_part.add_child(instance)
	instance.position = possible_nodes[0][0].position
	return true

func check_close_nodes(pos, dir):
	var list_nodes = []
	
	var dir_from = dir
	var vectorDir = Vector2(0,0)
	if dir_from == "right":
		vectorDir = Vector2(1,0)
	elif dir_from == "left":
		vectorDir = Vector2(-1,0)
	elif dir_from == "up":
		vectorDir = Vector2(0,-1)
	elif dir_from == "down":
		vectorDir = Vector2(0,1)
	for x in range(-1,2,2):
		if vectorDir != Vector2(pos.x+x,pos.y)-pos and Vector2(pos.x+x,pos.y) in dict_tracks:
			var node = check_node(dict_tracks[Vector2(pos.x+x,pos.y)]["obj"],pos-Vector2(pos.x+x,pos.y))
			if node != null:
				list_nodes.append(node)
	for y in range(-1,2,2):
		if vectorDir != Vector2(pos.x,pos.y+y)-pos and Vector2(pos.x,pos.y+y) in dict_tracks:
			var node = check_node(dict_tracks[Vector2(pos.x,pos.y+y)]["obj"], pos-Vector2(pos.x,pos.y+y))
			if node != null:
				list_nodes.append(node)
	return list_nodes
	

func check_node(node, dir):
	#all param number
	var nb_param_x = 0
	var nb_param_y = 0
	for elt in node.param_track.for_x:
		if elt != "":
			nb_param_x+=1
	for elt in node.param_track.for_y:
		if elt != "":
			nb_param_y+=1
		
	var vectorDir = "left"
	if dir == Vector2(1,0):
		vectorDir = "right"
	elif dir == Vector2(0,-1):
		vectorDir = "up"
	elif dir == Vector2(0,1):
		vectorDir = "down"
		
	#case 1 : 2 params only
	if nb_param_x + nb_param_y == 2:
		if vectorDir in node.param_track.for_y or vectorDir in node.param_track.for_x:
			return [node,vectorDir]
	#case 2 : 3 params
	else:
		if nb_param_x == 2:
			if vectorDir in node.param_track.for_x:
				var ind = get_ind(node.param_track.for_y)
				if node.param_track.for_x[ind] == vectorDir:
					return [node,vectorDir]
					
			#this means we only select one node
			if vectorDir in node.param_track.for_y:
				var ind = get_ind(node.param_track.for_y)
				banned_nodes.append(node.param_track.for_x[(ind+1)%2])
				return [node,vectorDir]
			
		if nb_param_y == 2:
			if vectorDir in node.param_track.for_y:
				var ind = get_ind(node.param_track.for_x)
				if node.param_track.for_y[ind] == vectorDir:
					return [node,vectorDir]
				
			#this means we only select one node
			if vectorDir in node.param_track.for_x:
				var ind = get_ind(node.param_track.for_x)
				banned_nodes.append(node.param_track.for_y[(ind+1)%2])
				return [node,vectorDir]
	
func get_ind(param):
	if param[0] != "":
		return 0
	if param[1] != "":
		return 1

func distance(a,b):
	return sqrt((a.x-b.x)**2+(a.y-b.y)**2)

func dict_set_up():
	for elt in get_children():
		var pos = Vector2(elt.position.x/25,elt.position.y/25)
		dict_tracks[pos] = {
			"Type": elt.type,
			"obj" : elt
		}

func _unhandled_input(event: InputEvent) -> void:
	if is_placing:
		if Input.is_action_just_pressed("click"):
			can_placement()
			if can_place:
				var instance = track_list[index].instantiate()
				instance.position = mouse_pos*25
				audio_manager.place_track_a(instance.position)
				play_explosion(instance.position)
				add_child(instance)
				dict_tracks[mouse_pos] = {
					"Type": instance.type,
					"obj" : instance
				}
				if train_main!=null:
					train_main.money -= int(button_down.get_child(index).get_child(2).text)
			else:
				if mouse_pos in dict_tracks:
					audio_manager.dest_track_a(mouse_pos*25)
					dict_tracks[mouse_pos]["obj"].queue_free()
					dict_tracks.erase(mouse_pos)
		if Input.is_action_just_pressed("escape"):
			is_placing = false
			selector_game.visible = false
			selected_button = null
			selector.visible = false

func play_explosion(pos):
	var place_effect = PLACE_EFFECT.instantiate()
	add_child(place_effect)
	place_effect.position=pos
	place_effect.emitting = true
	place_effect.get_child(0).emitting = true

func _physics_process(delta: float) -> void:
	
	if is_placing:
		var first_pos =Vector2(game.get_global_mouse_position().x,game.get_global_mouse_position().y)
		if first_pos.x>0:
			first_pos.x+=12.5
		else:
			first_pos.x-=12.5
		if first_pos.y>0:
			first_pos.y+=12.5
		else:
			first_pos.y-=12.5
		mouse_pos = check_grid_pos(first_pos)
		
		selector_game.position = mouse_pos*25
		if can_place:
			selector_game.play("can")
		else:
			selector_game.play("cannot")
		selector_game.queue_redraw()
		
		can_placement()

func can_placement():
	if mouse_pos in dict_tracks.keys() or selector_game.can_place == false:
		can_place = false
	else:
		can_place = true

func check_grid_pos(pos):
	var pos_x = int(pos.x/25)
	var pos_y = int(pos.y/25)
	return Vector2(pos_x, pos_y)

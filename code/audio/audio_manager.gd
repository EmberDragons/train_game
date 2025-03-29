extends Node2D
#all sounds
@onready var building_up: AudioStreamPlayer2D = $BUILDING_UP
@onready var brakes: AudioStreamPlayer2D = $"../train_part/train_main/audio/BRAKES"
@onready var train_horn: AudioStreamPlayer2D = $"../train_part/train_main/audio/TRAIN_HORN"
@onready var train_running: AudioStreamPlayer2D = $"../train_part/train_main/audio/TRAIN_RUNNING"

const PLACE_TRACK = preload("res://audio/obj/place_track.tscn")
const SELECT = preload("res://audio/obj/select.tscn")
const EXPLOSION = preload("res://audio/obj/explosion.tscn")
@onready var train_main: CharacterBody2D = $"../train_part/train_main"

@onready var bin: Node2D = $"../BIN"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func explosion_a(pos):
	var inst = EXPLOSION.instantiate()
	inst.position=pos
	bin.add_child(inst)
	var pitch = generate_pitch(0.85,1.15)
	var vol = generate_volumne(-1,1)
	inst.pitch_scale=pitch
	inst.volume_db=vol
	inst.play()
	
func place_track_a(pos):
	var inst = PLACE_TRACK.instantiate()
	inst.position=pos
	bin.add_child(inst)
	var pitch = generate_pitch(0.7,0.9)
	var vol = generate_volumne(-2,1)
	inst.pitch_scale=pitch
	inst.volume_db=vol
	inst.play()
	
func dest_track_a(pos):
	var inst = PLACE_TRACK.instantiate()
	inst.position=pos
	bin.add_child(inst)
	var pitch = generate_pitch(1.2,1.4)
	var vol = generate_volumne(-2,1)
	inst.pitch_scale=pitch
	inst.volume_db=vol
	inst.play()
	
	
func select_a():
	var inst = SELECT.instantiate()
	bin.add_child(inst)
	if train_main != null:
		inst.position=train_main.position
	var pitch = generate_pitch(0.9,1.2)
	var vol = generate_volumne(-2,2)
	inst.pitch_scale=pitch
	inst.volume_db=vol
	inst.play()
	
func tab_a():
	var inst = SELECT.instantiate()
	bin.add_child(inst)
	if train_main != null:
		inst.position=train_main.position
	var pitch = generate_pitch(0.4,0.6)
	var vol = generate_volumne(-2,2)
	inst.pitch_scale=pitch
	inst.volume_db=vol
	inst.play()
	
	
func train_running_a(speed):
	train_running.volume_db = -40 + (speed)*35
	
	
func station_building_a(pos,volumne=0):
	if volumne == 0:
		var pitch = generate_pitch(0.9,1.3)
		var vol = generate_volumne(-18,-10)
		building_up.position=pos
		building_up.pitch_scale=pitch
		building_up.volume_db=2
		building_up.play()
		station_building_a(pos,vol)
	else:
		building_up.volume_db+=2
		await get_tree().create_timer(0.1).timeout 
		if building_up.volume_db<volumne:
			station_building_a(pos,volumne)
	
func stop_building_a():
	building_up.volume_db -=2
	await get_tree().create_timer(0.1).timeout 
	if building_up.volume_db>=-50:
		stop_building_a()
	
	
func train_horn_a(pos):
	var pitch = generate_pitch(0.9,1.2)
	var vol = generate_volumne(-25,-15)
	train_horn.position=pos
	train_horn.pitch_scale=pitch
	train_horn.volume_db=vol
	train_horn.play()
	
func train_brakes(pos):
	var pitch = generate_pitch(0.9,1.2)
	var vol = generate_volumne(1,3)
	brakes.position=pos
	brakes.pitch_scale=pitch
	brakes.volume_db=vol
	brakes.play()

func train_starting_a():
	var pitch = generate_pitch(0.9,1.2)
	var vol = generate_volumne(-8,-4)
	train_horn.pitch_scale=pitch
	train_horn.volume_db=vol
	train_horn.play()

func generate_pitch(a,b):
	return randf_range(a,b)
	
func generate_volumne(a,b):
	return randf_range(a,b)

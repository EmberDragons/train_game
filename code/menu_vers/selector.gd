extends Node2D
@onready var button: Button = $Control/Button
@export var param = "volume"

var state = true
@onready var control: AnimatedSprite2D = $control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_set_up()



func button_set_up():
	if param == "optimisation":
		button.button_down.connect(optimisation_func)
		
	if param == "music":
		button.button_down.connect(music_func)
		
	if param == "shader":
		button.button_down.connect(shader_func)

func optimisation_func():
	if state == true:
		control.play("right")
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		state = false
	else:
		control.play("left")
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		state = true
		
func music_func():
	if state == true:
		control.play("right")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("MUSIC"), true)
		state = false
	else:
		control.play("left")
		AudioServer.set_bus_mute(AudioServer.get_bus_index("MUSIC"), false)
		state = true
		
func shader_func():
	if state == true:
		control.play("right")
		VarSaver.hasShaders = false
		state = false
	else:
		control.play("left")
		VarSaver.hasShaders = true
		state = true

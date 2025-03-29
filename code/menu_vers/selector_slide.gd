extends Node2D
@onready var slider: HSlider = $Control/HSlider

@export_enum("Master","SFX","MUSIC") var bus_name : String
@export var param = "volume"

var index=0
@onready var control: AnimatedSprite2D = $control

var last_value = 0
# Called when the node enters the scene tree for the first time.

func _process(delta: float) -> void:
	if slider.value != last_value:
		music_func()

func music_func():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), linear_to_db(slider.value/100))
	control.frame = int((slider.value)/25)

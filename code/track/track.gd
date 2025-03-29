extends StaticBody2D

@export var old_for_x : Array[String]
@export var old_for_y : Array[String]
@onready var button: Button = $Control/Button
@onready var track_graphics: AnimatedSprite2D = $AnimatedSprite2D
@onready var control: AnimatedSprite2D = $control

var param_track = parameters_track.new()
var side = "right"
#-----------------------------------------------------------grid placement part--------------------------------------
@export var type : String


func _ready() -> void:
	param_track.innit(old_for_x,old_for_y)
	if button != null:
		button.button_down.connect(Pressed)

func Pressed() :
	if side=="left":
		side="right"
	elif side=="right":
		side="left"
	control.play(side)
	track_graphics.play(side)
	param_track.reverse()

class parameters_track :
	var for_x = ["", ""]
	var for_y = ["", ""]
	
	func innit(x,y):
		for_x=[x[0],x[1]]
		for_y=[y[0],y[1]]

	# Called when the node enters the scene tree for the first time.
	func reverse():
		if "" not in for_x:
			for_x.reverse()
		if "" not in for_y:
			for_y.reverse()

	func show_x():
		return for_x
	func show_y():
		return for_y

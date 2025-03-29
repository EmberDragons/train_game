extends Node2D

@onready var shaders: Node2D = $shaders

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Engine.time_scale=1.0
	disable_shaders()

func disable_shaders():
	if VarSaver.hasShaders==false and shaders.visible == true:
		shaders.visible = false 
	if VarSaver.hasShaders==true and shaders.visible == false:
		shaders.visible = true 

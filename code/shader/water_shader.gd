@tool
extends Sprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	zoom_set_up()


func zoom_set_up():
	material.set_shader_parameter("y_zoom", get_viewport_transform().get_scale().y)
	material.set_shader_parameter("scale", scale)

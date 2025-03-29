extends TileMapLayer

@onready var camera_2d: Camera2D = $"../../Camera2D"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = camera_2d.position

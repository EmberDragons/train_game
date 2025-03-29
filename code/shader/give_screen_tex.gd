extends Node2D

@onready var subviewport = $".." # Sous-Viewport qui capture la caméra

@onready var sprite_reflection = $Sprite2D  # Sprite qui affiche la réflexion
@onready var shaders: Node2D = $"../../shaders"

func _ready():
	# Forcer le SubViewport à se mettre à jour en temps réel
	subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

func _process(delta):
	# Synchroniser la caméra du SubViewport avec la caméra principale
	var main_camera = get_viewport().get_camera_2d()
	if main_camera:
		position = main_camera.position  # Même position
		self.zoom = main_camera.zoom  # Même zoom

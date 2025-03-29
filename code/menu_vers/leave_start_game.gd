extends Node2D



func start():
	
	get_tree().change_scene_to_file("res://scene/game.tscn")

func leave():
	get_tree().quit()

func _on_leave_area_entered(area: Area2D) -> void:
	if area.is_in_group("train"):
		leave()


func _on_start_area_entered(area: Area2D) -> void:
	if area.is_in_group("train"):
		start()
		

class_name Screen_Transition
extends Node2D
 
@onready var camera_2d: Camera2D = $".."
@onready var player: Node2D = get_tree().get_first_node_in_group("player")
 
var moving_camera: bool = false
 
@onready var area_2d_up: Area2D = $Area2D_Up
@onready var area_2d_down: Area2D = $Area2D_Down
@onready var area_2d_left: Area2D = $Area2D_Left
@onready var area_2d_right: Area2D = $Area2D_Right
 
 
func disable_borders() -> void:
	area_2d_up.set_deferred("monitoring", false)
	area_2d_down.set_deferred("monitoring", false)
	area_2d_left.set_deferred("monitoring", false)
	area_2d_right.set_deferred("monitoring", false)
 
func enable_borders() -> void:
	area_2d_up.set_deferred("monitoring", true)
	area_2d_down.set_deferred("monitoring", true)
	area_2d_left.set_deferred("monitoring", true)
	area_2d_right.set_deferred("monitoring", true)
 
 
func _on_area_2d_up_body_entered(body: Node2D) -> void:
	if body == player and not moving_camera:
		moving_camera = true
		disable_borders()
		await player.move_transition_player(Vector2.UP, 20)
		var new_position_camera = camera_2d.position + Vector2(0, -176)
		var tween = create_tween()
		tween.tween_property(camera_2d, "position", new_position_camera, 0.8)
		await tween.finished
		enable_borders()
		moving_camera = false
		player.can_move = true
 
func _on_area_2d_down_body_entered(body: Node2D) -> void:
	if body == player and not moving_camera:
		moving_camera = true
		disable_borders()
		await player.move_transition_player(Vector2.DOWN, 20)
		var new_position_camera = camera_2d.position + Vector2(0, 176)
		var tween = create_tween()
		tween.tween_property(camera_2d, "position", new_position_camera, 0.8)
		await tween.finished
		enable_borders()
		moving_camera = false
		player.can_move = true
 
func _on_area_2d_left_body_entered(body: Node2D) -> void:
	if body == player and not moving_camera:
		moving_camera = true
		disable_borders()
		await player.move_transition_player(Vector2.LEFT, 20)
		var new_position_camera = camera_2d.position + Vector2(-256, 0)
		var tween = create_tween()
		tween.tween_property(camera_2d, "position", new_position_camera, 0.8)
		await tween.finished
		enable_borders()
		moving_camera = false
		player.can_move = true
 
func _on_area_2d_right_body_entered(body: Node2D) -> void:
	if body == player and not moving_camera:
		moving_camera = true
		disable_borders()
		await player.move_transition_player(Vector2.RIGHT, 20)
		var new_position_camera = camera_2d.position + Vector2(256, 0)
		var tween = create_tween()
		tween.tween_property(camera_2d, "position", new_position_camera, 0.8)
		await tween.finished
		enable_borders()
		moving_camera = false
		player.can_move = true
# En screen_transition.gd, dentro de _ready(), agrega:
		camera_2d.zoom = Vector2(2.0, 2.0)

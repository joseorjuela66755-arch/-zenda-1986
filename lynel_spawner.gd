extends Node
## lynel_spawner.gd — Instancia Lynel en runtime si no está en la escena.

@export var lynel_scene: PackedScene = preload("res://Lynel.tscn")
@export var spawn_position: Vector2 = Vector2(1200, 400)

func _ready() -> void:
	# Evita duplicados si ya existe un Lynel en la escena
	if get_tree().get_first_node_in_group("enemies_lynel") != null:
		return

	var lynel := lynel_scene.instantiate()
	lynel.global_position = spawn_position
	lynel.add_to_group("enemies_lynel")
	get_parent().add_child.call_deferred(lynel)

extends Area2D
## bomerang.gd — Proyectil bumerang del Lynel.

@export var SPEED: float = 150.0
@export var LIFETIME: float = 3.0
@export var ROTATION_SPEED: float = 720.0

var direction: Vector2 = Vector2.RIGHT
var damage: int = 1

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("enemy_projectiles")
	set_deferred("monitoring", false)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		set_deferred("monitoring", true)
	await get_tree().create_timer(LIFETIME).timeout
	if is_instance_valid(self):
		queue_free()

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta
	if sprite != null:
		sprite.rotation_degrees += ROTATION_SPEED * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage, direction)
		queue_free()
	elif body.is_in_group("world"):
		queue_free()

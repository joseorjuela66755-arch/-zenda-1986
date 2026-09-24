extends CharacterBody2D
 
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
 
@onready var ray_cast_2d_right: RayCast2D = $RayCast2D_RIGHT
@onready var ray_cast_2d_left: RayCast2D = $RayCast2D_LEFT
@onready var ray_cast_2d_up: RayCast2D = $RayCast2D_UP
@onready var ray_cast_2d_down: RayCast2D = $RayCast2D_DOWN
 
@export var SPEED: float = 30.0
 
var direction: Vector2 = Vector2.DOWN
 
var array_directions: Array = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.RIGHT,
	Vector2.LEFT
]
 
 
func _ready() -> void:
	add_to_group("enemies")
	direction = array_directions.pick_random()
 
 
func _physics_process(_delta: float) -> void:
	if direction.x > 0:
		animated_sprite_2d.play("walk_right")
	elif direction.x < 0:
		animated_sprite_2d.play("walk_left")
	elif direction.y < 0:
		animated_sprite_2d.play("walk_up")
	elif direction.y > 0:
		animated_sprite_2d.play("walk_down")
 
	velocity = direction * SPEED
	move_and_slide()
 
	if direction == Vector2.UP and ray_cast_2d_up.is_colliding():
		change_direction()
	elif direction == Vector2.DOWN and ray_cast_2d_down.is_colliding():
		change_direction()
	elif direction == Vector2.RIGHT and ray_cast_2d_right.is_colliding():
		change_direction()
	elif direction == Vector2.LEFT and ray_cast_2d_left.is_colliding():
		change_direction()
 
 
func change_direction() -> void:
	var available_directions: Array = []
 
	if not ray_cast_2d_up.is_colliding():
		available_directions.append(Vector2.UP)
	if not ray_cast_2d_down.is_colliding():
		available_directions.append(Vector2.DOWN)
	if not ray_cast_2d_right.is_colliding():
		available_directions.append(Vector2.RIGHT)
	if not ray_cast_2d_left.is_colliding():
		available_directions.append(Vector2.LEFT)
 
	if available_directions.is_empty():
		return
 
	direction = available_directions.pick_random()
 
 
func _on_timer_timeout() -> void:
	change_direction()

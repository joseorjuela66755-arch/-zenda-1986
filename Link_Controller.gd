extends CharacterBody2D

@export var SPEED: float = 60.0
@export var MAX_HEALTH: int = 6
@export var ATTACK_DURATION: float = 0.25
@export var INVULN_TIME: float = 0.6
@export var KNOCKBACK_SPEED: float = 90.0
@export var KNOCKBACK_TIME: float = 0.15

var health: int
var direction: Vector2 = Vector2.DOWN
var is_attacking: bool = false
var is_invulnerable: bool = false
var can_move: bool = true
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword_hitbox: Area2D = get_node_or_null("SwordHitBox")
@onready var sword_hitbox_shape: CollisionShape2D = get_node_or_null("SwordHitBox/CollisionShape2D")


func _ready() -> void:
	add_to_group("player")
	health = MAX_HEALTH
	if sword_hitbox_shape:
		sword_hitbox_shape.disabled = true


func _physics_process(delta: float) -> void:
	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity = knockback_velocity
		move_and_slide()
		return

	if not can_move or is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		_handle_attack_input()
		return

	var input_vector: Vector2 = Input.get_vector("IZQUIERDA", "DERECHA", "ARRIBA", "ABAJO")

	if input_vector != Vector2.ZERO:
		direction = input_vector.normalized()
		velocity = direction * SPEED
		animated_sprite_2d.play("walk_%s" % _direction_to_suffix(direction))
	else:
		velocity = Vector2.ZERO
		animated_sprite_2d.play("Idle")

	move_and_slide()
	_handle_attack_input()


func _handle_attack_input() -> void:
	if Input.is_action_just_pressed("ATACAR") and not is_attacking:
		_start_attack()


func _direction_to_suffix(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"


func _start_attack() -> void:
	is_attacking = true
	animated_sprite_2d.play("sword_%s" % _direction_to_suffix(direction))
	if sword_hitbox:
		sword_hitbox.position = direction * 8.0
	if sword_hitbox_shape:
		sword_hitbox_shape.disabled = false
	await get_tree().create_timer(ATTACK_DURATION).timeout
	if sword_hitbox_shape:
		sword_hitbox_shape.disabled = true
	is_attacking = false


func move_transition_player(dir: Vector2, amount: float) -> void:
	can_move = false
	velocity = Vector2.ZERO
	var tween := create_tween()
	tween.tween_property(self, "position", position + dir * amount, 0.3)
	await tween.finished


func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_invulnerable:
		return

	health -= amount
	if health <= 0:
		health = 0
		_die()
		return

	is_invulnerable = true
	knockback_velocity = knockback_dir * KNOCKBACK_SPEED
	knockback_timer = KNOCKBACK_TIME
	modulate = Color(1, 0.5, 0.5)
	await get_tree().create_timer(INVULN_TIME).timeout
	modulate = Color(1, 1, 1)
	is_invulnerable = false


func _die() -> void:
	set_physics_process(false)
	queue_free()


func _on_sword_hit_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(1)

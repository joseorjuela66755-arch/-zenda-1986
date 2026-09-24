extends CharacterBody2D
## lynel.gd — Enemigo élite Lynel con patrulla, persecución, embestida y ataque a distancia.

# ===================== FASE 1: valores base =====================
@export var SPEED_PATROL: float      = 25.0
@export var SPEED_CHASE: float       = 45.0
@export var CHARGE_SPEED: float      = 110.0
@export var DETECTION_RANGE: float   = 90.0
@export var ATTACK_RANGE: float      = 20.0
@export var WINDUP_TIME: float       = 0.4
@export var CHARGE_DURATION: float   = 0.5
@export var CHARGE_COOLDOWN: float   = 1.0

# ===================== FASE 2: enfurecido =====================
@export var ENRAGE_HEALTH_RATIO: float      = 0.5
@export var ENRAGE_SPEED_MULTIPLIER: float  = 1.6
@export var ENRAGE_WINDUP_TIME: float       = 0.15

# ===================== ATAQUE A DISTANCIA =====================
@export var RANGED_ATTACK_RANGE: float = 250.0
@export var RANGED_COOLDOWN: float     = 3.0
@export var IS_RED_VARIANT: bool       = false
@export var PROJECTILE_SCENE: PackedScene

@export var MAX_HEALTH: int = 6
var health: int

enum State { PATROL, CHASE, WINDUP, CHARGE, RANGED, COOLDOWN, HURT, DEAD }
var state: State = State.PATROL
var is_enraged: bool = false

var player: Node2D = null
var direction: Vector2 = Vector2.DOWN
var array_directions: Array[Vector2] = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var ranged_timer: float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_shape: CollisionShape2D      = $AttackHitbox/CollisionShape2D
@onready var state_timer: Timer                  = $StateTimer
@onready var ray_up: RayCast2D                   = $RayCast2D_UP
@onready var ray_down: RayCast2D                 = $RayCast2D_DOWN
@onready var ray_left: RayCast2D                 = $RayCast2D_LEFT
@onready var ray_right: RayCast2D                = $RayCast2D_RIGHT


func _ready() -> void:
	add_to_group("enemies")
	health = MAX_HEALTH
	direction = array_directions.pick_random()
	attack_shape.disabled = true


func _physics_process(delta: float) -> void:
	ranged_timer -= delta

	match state:
		State.PATROL:
			_process_patrol()
		State.CHASE:
			_process_chase()
		State.WINDUP, State.COOLDOWN, State.HURT, State.DEAD:
			velocity = Vector2.ZERO
		State.CHARGE:
			velocity = direction * CHARGE_SPEED
		State.RANGED:
			_process_ranged()

	move_and_slide()
	_update_animation()


# ---------------------------------------------------------------
# Patrulla (mismo patrón que Octorok)
# ---------------------------------------------------------------
func _process_patrol() -> void:
	velocity = direction * SPEED_PATROL

	if direction == Vector2.UP and ray_up.is_colliding():
		_change_wander_direction()
	elif direction == Vector2.DOWN and ray_down.is_colliding():
		_change_wander_direction()
	elif direction == Vector2.LEFT and ray_left.is_colliding():
		_change_wander_direction()
	elif direction == Vector2.RIGHT and ray_right.is_colliding():
		_change_wander_direction()


func _change_wander_direction() -> void:
	var available: Array[Vector2] = []
	if not ray_up.is_colliding():
		available.append(Vector2.UP)
	if not ray_down.is_colliding():
		available.append(Vector2.DOWN)
	if not ray_left.is_colliding():
		available.append(Vector2.LEFT)
	if not ray_right.is_colliding():
		available.append(Vector2.RIGHT)

	if available.is_empty():
		return
	direction = available.pick_random()


# ---------------------------------------------------------------
# Persecución + detección de rango para ataque a distancia
# ---------------------------------------------------------------
func _process_chase() -> void:
	if player == null:
		state = State.PATROL
		return

	var to_player: Vector2 = player.global_position - global_position
	var dist: float = to_player.length()
	direction = to_player.normalized()

	var speed: float = SPEED_CHASE * (ENRAGE_SPEED_MULTIPLIER if is_enraged else 1.0)
	velocity = direction * speed

	if dist <= ATTACK_RANGE:
		_start_windup()
	elif dist <= RANGED_ATTACK_RANGE and ranged_timer <= 0.0:
		_start_ranged()


# ---------------------------------------------------------------
# Windup → Charge → Cooldown
# ---------------------------------------------------------------
func _start_windup() -> void:
	state = State.WINDUP
	animated_sprite_2d.play("charge_%s" % _direction_to_suffix(direction))
	state_timer.wait_time = ENRAGE_WINDUP_TIME if is_enraged else WINDUP_TIME
	state_timer.start()


# ---------------------------------------------------------------
# Ataque a distancia (fireball)
# ---------------------------------------------------------------
func _process_ranged() -> void:
	velocity = Vector2.ZERO
	if player == null:
		state = State.COOLDOWN
		state_timer.wait_time = CHARGE_COOLDOWN
		state_timer.start()
		return
	direction = (player.global_position - global_position).normalized()
	animated_sprite_2d.play("charge_%s" % _direction_to_suffix(direction))


func _start_ranged() -> void:
	print("LYNEL INICIA RANGED | dist=", (player.global_position - global_position).length())
	state = State.RANGED
	ranged_timer = RANGED_COOLDOWN
	state_timer.wait_time = 0.5
	state_timer.start()


func _spawn_projectile() -> void:
	print("LYNEL DISPARA | PROJECTILE_SCENE=", PROJECTILE_SCENE)
	if PROJECTILE_SCENE == null:
		print("  ERROR: PROJECTILE_SCENE es null")
		return
	var projectile = PROJECTILE_SCENE.instantiate()
	projectile.global_position = global_position
	projectile.direction = direction
	projectile.damage = 2 if IS_RED_VARIANT else 1
	get_parent().add_child(projectile)
	print("  BOMERANG INSTANCIADO en ", projectile.global_position)


# ---------------------------------------------------------------
# Timer (transiciones de estados temporizados)
# ---------------------------------------------------------------
func _on_state_timer_timeout() -> void:
	match state:
		State.WINDUP:
			state = State.CHARGE
			attack_shape.disabled = false
			state_timer.wait_time = CHARGE_DURATION
			state_timer.start()
		State.CHARGE:
			attack_shape.disabled = true
			state = State.COOLDOWN
			state_timer.wait_time = CHARGE_COOLDOWN
			state_timer.start()
		State.RANGED:
			_spawn_projectile()
			state = State.COOLDOWN
			state_timer.wait_time = CHARGE_COOLDOWN
			state_timer.start()
		State.COOLDOWN:
			state = State.CHASE if player != null else State.PATROL
		State.HURT:
			state = State.CHASE if player != null else State.PATROL


# ---------------------------------------------------------------
# Utilidades de animación
# ---------------------------------------------------------------
func _direction_to_suffix(dir: Vector2) -> String:
	if abs(dir.x) > abs(dir.y):
		return "right" if dir.x > 0 else "left"
	return "down" if dir.y > 0 else "up"


func _update_animation() -> void:
	if state in [State.WINDUP, State.CHARGE, State.RANGED, State.HURT, State.DEAD]:
		return
	animated_sprite_2d.play("walk_%s" % _direction_to_suffix(direction))


# ---------------------------------------------------------------
# Señales de Area2D
# ---------------------------------------------------------------
func _on_detection_area_body_entered(body: Node2D) -> void:
	print("LYNEL DETECTA: ", body.name, " | grupo player: ", body.is_in_group("player"))
	if body.is_in_group("player") and state == State.PATROL:
		player = body
		state = State.CHASE


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		if state == State.CHASE:
			state = State.PATROL


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		var knockback_dir: Vector2 = (body.global_position - global_position).normalized()
		var damage: int = 2 if is_enraged else 1
		body.take_damage(damage, knockback_dir)


# ---------------------------------------------------------------
# Daño recibido / fase enraged / muerte
# ---------------------------------------------------------------
func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return

	health -= amount
	if health <= 0:
		_die()
		return

	state = State.HURT
	animated_sprite_2d.play("hurt_%s" % _direction_to_suffix(direction))
	state_timer.wait_time = 0.3
	state_timer.start()

	if not is_enraged and float(health) / float(MAX_HEALTH) <= ENRAGE_HEALTH_RATIO:
		_enter_enraged_phase()
	health -= amount
	if health <= 0:
		_die()
		return

func _enter_enraged_phase() -> void:
	is_enraged = true
	modulate = Color(1.0, 0.55, 0.55)


func _die() -> void:
	state = State.DEAD
	attack_shape.disabled = true
	velocity = Vector2.ZERO

	# Verifica si la animación "death" existe antes de reproducirla
	if animated_sprite_2d.sprite_frames.has_animation("death") \
		and animated_sprite_2d.sprite_frames.get_frame_count("death") > 0:
		animated_sprite_2d.play("death")
		await animated_sprite_2d.animation_finished
	else:
		# Fallback: espera 0.5s fijos y desaparece
		await get_tree().create_timer(0.5).timeout

	queue_free()

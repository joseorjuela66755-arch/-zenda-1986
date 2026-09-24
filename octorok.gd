extends CharacterBody2D

#Referencia a las animaciones
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D



#Referencias para los RayCast
@onready var ray_cast_2d_right: RayCast2D = $RayCast2D_RIGHT
@onready var ray_cast_2d_left: RayCast2D = $RayCast2D_LEFT
@onready var ray_cast_2d_up: RayCast2D = $RayCast2D_UP
@onready var ray_cast_2d_down: RayCast2D = $RayCast2D_DOWN

#Variable para aplicar la velovidad de desplazamiento
@export var SPEED : float = 30.0

#Variable para comprobar la direccion del enemigo y asi reproducir las animaciones
var direction : Vector2 = Vector2.DOWN

#Crear un arreglo para que el enemigo elija de forma aleatoria una direccion
var array_directions : Array = [
	Vector2.UP, 
	Vector2.DOWN, 
	Vector2.RIGHT, 
	Vector2.LEFT
	]
	
	
#Selecionar una de las direcciones
func _ready() -> void:
	add_to_group("enemies")
	direction = array_directions.pick_random()
	
#Hacemos las comprobaciones
func _physics_process(delta: float) -> void:
	
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
	
	#Detectar cuando los raycast han colisionado con un obstaculo o con una pared
	if direction == Vector2.UP and ray_cast_2d_up.is_colliding():
		change_direction()
	elif direction == Vector2.DOWN and ray_cast_2d_down.is_colliding():
		change_direction()
	elif direction == Vector2.RIGHT and ray_cast_2d_right.is_colliding():
		change_direction()
	elif direction == Vector2.LEFT and ray_cast_2d_left.is_colliding():
		change_direction()
	
	
	
	
#Crar una funcion para el cambio de direccion
func change_direction()->void:
	#Este arreglo va almacenar las direcciones disponibles, donde no se detecte collision u obstaculos.
	var available_directions: Array = []
	
	if not ray_cast_2d_up.is_colliding():
		available_directions.append(Vector2.UP)
	if not ray_cast_2d_down.is_colliding():
		available_directions.append(Vector2.DOWN)
	if not ray_cast_2d_right.is_colliding():
		available_directions.append(Vector2.RIGHT)
	if not  ray_cast_2d_left.is_colliding():
		available_directions.append(Vector2.LEFT)
		
		
	#Hacer otra validacion y es si el enemigo no tiene caminos disponibles
	if available_directions.is_empty():
		return
	
	direction = available_directions.pick_random()
	
	print("OBSTACULO DETECTADO")
	

func _on_timer_timeout() -> void:
	change_direction()

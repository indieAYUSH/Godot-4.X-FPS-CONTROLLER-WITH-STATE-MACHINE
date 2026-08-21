class_name PlayerController  extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5


@onready var head = %head
@onready var crouched_collsion_shape = $crouched_collsion_shape
@onready var uncrouched_collision_shape = $uncrouched_collision_shape
@onready var obstacle_checker = %ShapeCast3D
@onready var player_animation = $PlayerAnimation
@onready var lobschecker: ShapeCast3D = %Lobschecker
@onready var r_obscheckr: ShapeCast3D = %RObscheckr
@onready var free_look_pivot: Node3D = %FreeLookPivot

@export_category("Component Refrences")
@export var player_statemachine : StateMachine
@export var CameraJuice_Component : CameraJuiceComponent
@export var state_ref : State
@export var itme_holdable : item_holder
@export var audio_manager : AudioManager

@export_category("Movement Bools")
@export var can_dash : bool = true

@export_group("Movement vars")
@export var air_resistance : float = 0.5

@export_group("Wall jump and run")
@export var wall_push_force : float = 4.5
@export var max_wall_jump : float = 2.0
@export var wall_jump_retention : float = 1.0
@export var wall_run_velocity_threshold : float = 9.0






var input_dir
var freezed : bool = false
@onready var camera_3d = %Camera3D
var free_look : bool = false


var door_key  : bool = false
var current_movement_direction : Vector3


#Signals
signal unfreezeplayer

func _ready():
	obstacle_checker.add_exception(self)
	lobschecker.add_exception(self)
	r_obscheckr.add_exception(self)
	Global.Player = self

func _physics_process(delta):
	current_movement_direction = Vector3(velocity.x , 0.0 , velocity.z).normalized()
	move_and_slide()









func _update_rotation(rot_value : Vector3) -> void :
	transform.basis = Basis.from_euler(rot_value)


#func input_direction()->void:
	#input_dir



func update_movement(_speed : float , _acceleration : float , Deacceleration :float ):
	input_dir = Input.get_vector("left", "right", "forward", "baackward")
	var horizontal_velocity : Vector3 = Vector3(velocity.x , 0.0 , velocity.y)
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = lerp(velocity.x , direction.x * _speed , _acceleration)
		velocity.z = lerp(velocity.z , direction.z * _speed , _acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0,  Deacceleration)
		velocity.z = move_toward(velocity.z, 0,  Deacceleration)

func reset_movement():
	velocity.x = move_toward(velocity.x, 0,  0.9)
	velocity.z = move_toward(velocity.z, 0,  0.9)

func apply_air_resistance(delta:float):
	var horizontal_velocity : Vector3 = Vector3(velocity.x , 0 , velocity.z)
	horizontal_velocity *= exp(-air_resistance*delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

func update_air_movement(dir , delta:float , input_multiplier : float , air_control:float ,) -> void:
	apply_air_resistance(delta)
	input_dir = Input.get_vector("left" , "right" , "forward" , "baackward")
	
	if input_dir == Vector2.ZERO:
		return
	
	var direction = (dir*Vector3(input_dir.x , 0 , input_dir.y)).normalized()
	var horizontal_velocity : Vector3 = Vector3(velocity.x , 0 , velocity.z)
	var desired_speed = horizontal_velocity.length()
	
	
	if desired_speed < 0.01:
		return
	
	var speed = desired_speed*direction
	horizontal_velocity.x = lerp(horizontal_velocity.x , speed.x , air_control)
	horizontal_velocity.z = lerp(horizontal_velocity.z , speed.z , air_control)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	

func wall_jump(wall_normal : Vector3 , jump_force : float , _wall_jump_retention , _wall_push_force : float):
	var horizontal_movement : Vector3  = Vector3(velocity.x , 0.0 , velocity.z)
	var horizonal_movement_vector = horizontal_movement.normalized()+wall_normal

	var target_speed = _wall_push_force+abs(horizontal_movement.length()*_wall_jump_retention)
	var target_velocity = horizonal_movement_vector*target_speed
	
	velocity.x = target_velocity.x
	velocity.z = target_velocity.z
	velocity.y = jump_force

func update_slide_movement(dir , _speed : float , _acceleration : float , Deacceleration :float ):
	input_dir = Input.get_vector("left", "right", "forward", "baackward")
	var direction = (dir * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x , direction.x * _speed , _acceleration)
		velocity.z = lerp(velocity.z , direction.z * _speed , _acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0,  Deacceleration)
		velocity.z = move_toward(velocity.z, 0,  Deacceleration)


func wall_run(_direction : Vector3 , _speed : float ) -> void:
	velocity = _direction * _speed

func update_gravity(delta , _gravity_multiplier : float):
	if not is_on_floor():
		velocity += get_gravity() * delta * _gravity_multiplier*1.1


func crouch():
	#head.position.y =  lerp(head.position.y ,  crouch_depth , lerp_speed *delta)
	crouched_collsion_shape.disabled = false
	uncrouched_collision_shape.disabled = true
	player_animation.play("crouch")

func uncrouch():
	#head.position.y =  lerp(head.position.y , 0.6 + crouch_depth , lerp_speed *delta)
	crouched_collsion_shape.disabled = true
	uncrouched_collision_shape.disabled = false
	player_animation.play("uncrouch")

func dash(direction: Vector3, speed: float) -> void:
	if direction.length() == 0:
		return
	var _direction = direction.normalized()
	_direction.y = 0  
	velocity = _direction * speed  

func freeze_player() ->void:
	player_statemachine.on_change_state("FreezeState")

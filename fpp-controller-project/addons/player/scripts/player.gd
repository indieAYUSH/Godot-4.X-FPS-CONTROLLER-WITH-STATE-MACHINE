class_name PlayerController  extends CharacterBody3D


@export  var max_speed : float = 14.0


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
@export var camera_controller : CameraControllerComponent
@export var stepper_component : StepperComponent
@export var ray_cast_component : RaycastComponent

@export_category("Movement Bools")
@export var can_dash : bool = true

@export_group("Movement vars")
@export var air_resistance : float = 0.5

@export_group("Wall jump and run")
@export var wall_push_force : float = 4.5
@export var max_wall_jump : float = 2.0
@export var wall_jump_retention : float = 1.0
@export var wall_run_velocity_threshold : float = 9.0
@export var wall_run_accel : float = 14.0
@export var wall_run_deaccel : float = 10.0

@export_group("sliding")
@export var slide_threshold_speed : float = 8.0

@export_group("Ground movement")
@export var ground_accel : float = 8.0
@export var ground_deaacel : float = 4.0

@export_group("air movment var")
@export var max_air_accel : float = 800.0
@export var max_air_speed : float = 500.0
@export var air_cap : float = 0.9

@export_group("vaulting and mantling")
@export var vault_time : float = 0.4
@export var vaulter : Vaulter 
var vault_timer : float

@export_group("jumping")
@export var coyote_time : float = 0.2
var current_coyote_time : float



var wish_dir


#var input_dir : Vector2
var freezed : bool = false
@onready var camera_3d = %Camera3D
var free_look : bool = false


var door_key  : bool = false
var current_movement_direction : Vector3
var current_speed : float
var current_horizontal_velocity : Vector3
var input_dir : Vector2
var last_frame_velocity : Vector3
#Signals
signal unfreezeplayer

func _ready():
	obstacle_checker.add_exception(self)
	lobschecker.add_exception(self)
	r_obscheckr.add_exception(self)
	Global.Player = self
	current_coyote_time = coyote_time


func _physics_process(delta):  
	current_horizontal_velocity = Vector3(velocity.x , 0.0 , velocity.z)
	current_movement_direction = Vector3(velocity.x , 0.0 , velocity.z).normalized()
	current_speed = velocity.length()
	move_and_slide()
	stepper_component._handle_step_climbing(delta)






func _update_rotation(rot_value : Vector3) -> void :
	transform.basis = Basis.from_euler(rot_value)

func _update_free_look_roation(rot_value:Vector3)->void :
	free_look_pivot.transform.basis = basis.from_euler(rot_value)

func clamp_y_rot(_min_rot_val , max_rot_val):
	rotation.y = clamp(rotation.y , deg_to_rad(_min_rot_val) , deg_to_rad(max_rot_val))





func update_movement(_speed : float ,  _delta : float  ):
	input_dir = Input.get_vector("left", "right", "forward", "baackward").normalized()
	var horizonatal_vel : Vector3 = Vector3(velocity.x , 0.0 , velocity.z)
	wish_dir = global_transform.basis*Vector3(input_dir.x , 0.0 , input_dir.y)
	var curr_wish_dir_speed = horizonatal_vel.dot(wish_dir)
	var add_speed = _speed - curr_wish_dir_speed
	
	if add_speed > 0.0:
		var acc_speed = _speed * _delta * ground_accel
		acc_speed = min(acc_speed , add_speed)
		velocity += acc_speed*wish_dir
	
	var control = max(current_horizontal_velocity.length() , ground_deaacel)
	var retard = ground_deaacel * _delta * control
	var new_Speed = max(velocity.length()-retard , 0.0)
	if velocity.length() > 0:
		new_Speed /= velocity.length()
	velocity.x *= new_Speed
	velocity.z *= new_Speed



func apply_air_resistance(delta:float):
	var horizontal_velocity : Vector3 = Vector3(velocity.x , 0 , velocity.z)
	horizontal_velocity *= exp(-air_resistance*delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

func update_air_movement(dir , delta:float , input_multiplier : float , air_control:float ) -> void:
	apply_air_resistance(delta)
	input_dir = Input.get_vector("left", "right", "forward", "baackward")
	
	var wish_dir = (global_transform.basis*Vector3(input_dir.x , 0 , input_dir.y)).normalized()
	var horizontal_velocity : Vector3 = Vector3(velocity.x , 0 , velocity.z)
	var speed_in_wish_dir = horizontal_velocity.dot(wish_dir)
	var capped_speed = min((max_air_speed*wish_dir).length() , air_cap)
	var add_speed = capped_speed - speed_in_wish_dir
	if add_speed > 0.0:
		var desired_speed = max_air_accel * delta * max_air_speed
		var accel_speed = min(desired_speed , add_speed)
		velocity += accel_speed * wish_dir
	
	


func wall_jump(wall_normal : Vector3 , jump_force : float , _wall_jump_retention , _wall_push_force : float):
	var horizontal_velocity : Vector3  = Vector3(velocity.x , 0.0 , velocity.z)
	
	var forward_velocity :=  horizontal_velocity.slide(wall_normal)
	var upward_speed = velocity.y
	
	var target_forw_speed := forward_velocity.length()*wall_jump_retention
	var forward_dir = forward_velocity.normalized()
	var target_for_vel = forward_dir*target_forw_speed
	
	var target_away_vel = wall_normal * wall_push_force
	var target_velocity = target_for_vel + target_away_vel
	
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


func wall_run(_direction : Vector3 , _speed : float , _acceleration : float , delta : float) -> void:
	var wall_run_direction := velocity.slide(_direction)
	wall_run_direction = wall_run_direction.normalized()
	var speed_in_parrl = velocity.dot(wall_run_direction)
	var add_speed = _speed - speed_in_parrl
	if add_speed > 0.0:
		var wall_accel_speed = _speed * wall_run_accel * delta
		wall_accel_speed = min(wall_accel_speed , add_speed)
		velocity += wall_run_direction * wall_accel_speed
	
	var wall_cont = max(current_horizontal_velocity.length() , wall_run_deaccel)
	var wall_retard = delta * wall_run_deaccel * wall_cont
	var new_speed = max(velocity.length() , 0.0)
	if new_speed > 0.0:
		new_speed /= velocity.length()
	velocity.x *= new_speed
	velocity.z *= new_speed

func update_gravity(delta , _gravity_multiplier : float):
	if not is_on_floor():
		velocity += get_gravity() * delta * _gravity_multiplier*1.1


func crouch():
	crouched_collsion_shape.disabled = false
	uncrouched_collision_shape.disabled = true
	player_animation.play("crouch")

func uncrouch():
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


func valid_wall_run()->bool:
	if is_on_wall() and velocity.y < 1.0 and Input.is_action_pressed("forward") and velocity.length()>wall_run_velocity_threshold:
		for i in get_slide_collision_count():
			var collision_surface = get_slide_collision(i)
			var collision_normal = collision_surface.get_normal()
			var dir_dot = -current_movement_direction.dot(collision_normal)
			if abs(dir_dot) > 0.05 and abs(dir_dot) < 0.85:
				return true 
	return false


func _vault_breeze(t : float , start_point : Vector3 , mid_point : Vector3 , end_point : Vector3)->void:
	var a = start_point.lerp(mid_point , t)
	var b = mid_point.lerp(end_point , t)
	global_position = a.lerp(b , t)

func _process(delta: float) -> void:
	if !is_on_floor():
		current_coyote_time -= delta

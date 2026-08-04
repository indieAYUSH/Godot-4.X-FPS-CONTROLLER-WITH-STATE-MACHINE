class_name CameraJuiceComponent extends Node3D

@export_category("Reffrences")
@export var camera : Camera3D
@onready var rot_pivot = %rot_pivot

@export_category("Camera Effects")
@export var Camera_tilt: bool
@export var Head_bob : bool
@export  var camer_fov_changes : bool


@export var Player : PlayerController
@export var lerp_speed : float = 15.0

@export_category("TILT VARS")
@export var roll_pitch : float = 0.031
@export var roll_side_rot : float  = 0.049
@export var max_speed : float = 9.0

@export_category("Headbob Vars")
@export_group("yaw and pitch headbob")
@export var bob_pitch : float = 0.05
@export var bob_roll : float = 0.025
@export var bob_up :float = 0.0005
@export var bob_frequncy : float = 7.0
@export_group("sinwave x y axis headbob")
@export var bob_frequency : float
@export var bob_amplitude : float



@export_group("Collision checker")
@export var left_collision_checker : ShapeCast3D
@export var right_collision_checker : ShapeCast3D
 

#--=====yaw and pitch only==-----#
var _step_timer : float = 0.0

#----===== x y axis disp only =====- --------#
var current_bob_amplitude : float
var current_bob_frquency : float
var current_roll : float  #used slightly to give more feel to head bob

var bob_offset_vector : Vector2

@export_category("FOV Vars")
var target_fov : float
@export var base_fov :float = 75.0

var rot_pivot_amount : float = 0.0
var rot_pivot_x_rot_amount : float = 0.0


func _ready():
	target_fov = base_fov

func _process(delta):
	camera_effects_manager(delta)


func camera_effects_manager(delta:float) -> void:
	var angles  = Vector3.ZERO
	var offsets = Vector3.ZERO
	var collider_value  = float(!left_collision_checker.is_colliding() and !right_collision_checker.is_colliding())
	var velocity = Player.velocity.length()
	
	
	#=======================CAMERA TILT things =================================================#
	if Player.velocity.length() > 0.01 and Camera_tilt:
		var speed_factor = clamp(velocity / max_speed, 0.0, 1.0)
		angles.x = lerp(rotation.x , (roll_pitch* Input.get_axis("forward","baackward"))*speed_factor , delta*lerp_speed)
		angles.z = lerp(rotation.z , -(roll_side_rot*Input.get_axis("left","right"))*speed_factor , lerp_speed*delta )
	
	
	#Headbob Things ===============================================================
	
	var speed = Vector2(Player.velocity.x , Player.velocity.z).length()
	
	#--======= i prefer x yt axis headbob so i am gonna use that by default
	#========= u can use onr according to ur neded
	
	#_+-----------========== roll yaw headbob===========----------------#
	
	#if speed > 0.1 and Player.is_on_floor()  :
		#_step_timer += delta*(speed/bob_frequncy)
		#_step_timer = fmod(_step_timer , 1.0)
	#else:
		#_step_timer = 0.0
	#var bob_sin = sin(_step_timer* 2.0 * PI) *0.5
	#
	#if Head_bob and _can_headbob():
		#var pitch_delta = bob_sin * deg_to_rad(bob_pitch) * speed
		#angles.x -= pitch_delta
		#
		#var roll_delta = bob_sin*deg_to_rad(bob_roll) * speed
		#angles.z -= roll_delta
		#
		#var up_delta = bob_sin * speed * bob_up
		#offsets.y += up_delta
	
	#--------=============sin wave x y axis disp  headbob -====================#
	
	if Head_bob:
		var bob_multiplier = float(Head_bob and Player.is_on_floor() and _can_headbob()) * collider_value
		current_bob_frquency += bob_frequency*speed*delta
		current_bob_amplitude = bob_amplitude*speed
		bob_offset_vector.x = (sin(current_bob_frquency/2.0)*current_bob_amplitude+0.2)*bob_multiplier
		bob_offset_vector.y = (sin(current_bob_frquency)*current_bob_amplitude - 0.02)*bob_multiplier
		current_roll = ((sin(current_bob_frquency)*current_bob_amplitude)/2.65)*bob_multiplier
		offsets.x = lerp(offsets.x , bob_offset_vector.x, delta*lerp_speed)
		offsets.y = lerp(offsets.y , bob_offset_vector.y/2.0, delta*lerp_speed)
		angles.z  = lerp(angles.z , deg_to_rad(current_roll) , delta*lerp_speed)
	rotation = angles
	position = offsets
	
	camera.fov = lerp(camera.fov , target_fov , lerp_speed*delta)
	
	#=================Rotation pivot settings================#
	rot_pivot.rotation.z = lerp(rot_pivot.rotation.z , deg_to_rad(rot_pivot_amount) , lerp_speed*delta)
	rot_pivot.rotation.x = lerp(rot_pivot.rotation.x , deg_to_rad(rot_pivot_x_rot_amount) , lerp_speed*delta)
	rot_pivot.rotation.x = clamp(rot_pivot.rotation.x , deg_to_rad(0.0) , deg_to_rad(15.0))


func fov_manager(amount:float) -> void:
	target_fov = base_fov + amount

func rot_pivot_manager(amount:float) -> void:
	rot_pivot_amount = amount

func _can_headbob() -> bool:
	var state_name = Player.player_statemachine.current_state.name
	# Headbob is allowed if the player is NOT sliding or dashing
	return state_name != "SlideState" and state_name != "DashState"

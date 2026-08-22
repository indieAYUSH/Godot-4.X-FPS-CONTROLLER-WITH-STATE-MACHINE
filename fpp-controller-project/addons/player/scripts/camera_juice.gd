class_name CameraJuiceComponent extends Node3D

@export_category("Reffrences")
@export var camera : Camera3D
@onready var rot_pivot = %rot_pivot
@onready var bob_head: Node3D = %bob_head

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
@export var base_fov :float = 85.0
@export var max_fov : float  = 110.0
@export var player_max_sped : float = 20.0

var rot_pivot_amount : float = 0.0
var rot_pivot_x_rot_amount : float = 0.0

enum CAMERA_STATE{default,GROUND_MOVEMENT , WALL_RUN}

var current_camera_state : CAMERA_STATE = CAMERA_STATE.GROUND_MOVEMENT


func _process(delta):
	camera_effects_manager(delta)
	fov_manager(delta)


func camera_effects_manager(delta:float) -> void:
	var angles  = Vector3.ZERO
	var offsets = Vector3.ZERO
	var velocity = Player.velocity.length()
	
	
	#=======================CAMERA TILT things =================================================#
	if Player.velocity.length() > 0.01 and Camera_tilt:
		var speed_factor = clamp(velocity / max_speed, 0.0, 1.0)
		angles.x = lerp(rotation.x , (roll_pitch* Input.get_axis("forward","baackward"))*speed_factor , delta*lerp_speed)
		angles.z = lerp(rotation.z , -(roll_side_rot*Input.get_axis("left","right"))*speed_factor , lerp_speed*delta )
	
	
	#Headbob Things ===============================================================
	
	var speed = Vector2(Player.velocity.x , Player.velocity.z).length()
	head_bob_manager(speed , delta)
	
	#--------=============sin wave x y axis disp  headbob -====================#
	
	
	#=================Rotation pivot settings================#
	rot_pivot.rotation.z = lerp(rot_pivot.rotation.z , deg_to_rad(rot_pivot_amount) , lerp_speed*delta)
	rot_pivot.rotation.x = lerp(rot_pivot.rotation.x , deg_to_rad(rot_pivot_x_rot_amount) , lerp_speed*delta)
	rot_pivot.rotation.x = clamp(rot_pivot.rotation.x , deg_to_rad(0.0) , deg_to_rad(15.0))
	rotation = angles
	position = offsets

func fov_manager(delta:float) -> void:
	var speed_ratio = clamp(Player.velocity.length()/player_max_sped , 0.0 , 1.0)
	target_fov = lerp(base_fov , max_fov , speed_ratio)
	#target_fov = clamp(target_fov , base_fov , max_fov)
	camera.fov = lerp(camera.fov, target_fov , delta*lerp_speed)

func rot_pivot_manager(amount:float) -> void:
	if rot_pivot_amount != amount:
		rot_pivot_amount = amount

func _can_headbob() -> bool:
	var state_name = Player.player_statemachine.current_state.name
	# Headbob is allowed if the player is NOT sliding or dashing
	return state_name != "SlideState" and state_name != "DashState"


func head_bob_manager(speed : float , delta : float)->void:
	var angles  = Vector3.ZERO
	var offsets = Vector3.ZERO
	var collider_value  = float(!left_collision_checker.is_colliding() and !right_collision_checker.is_colliding())
	
	match current_camera_state:
		CAMERA_STATE.default:
			pass
		
		
		CAMERA_STATE.GROUND_MOVEMENT:
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
			
			
		CAMERA_STATE.WALL_RUN:
			if Head_bob:
				var bob_multiplier = float(Head_bob and Player.is_on_wall() and _can_headbob()) * collider_value
				current_bob_frquency += bob_frequency*speed*delta
				current_bob_amplitude = bob_amplitude*speed
				bob_offset_vector.y = (sin(current_bob_frquency)*current_bob_amplitude - 0.02)*bob_multiplier
				current_roll = ((sin(current_bob_frquency)*current_bob_amplitude))*bob_multiplier
				angles.z  = lerp(angles.z , deg_to_rad(current_roll)*2.5 , delta*lerp_speed)
				
			
	bob_head.rotation = angles
	bob_head.position = offsets

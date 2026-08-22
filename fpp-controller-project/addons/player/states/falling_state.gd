class_name FallingState
extends PlayerMovementState

@export_category("Movement vars")
@export var speed : float = 7.5
@export var acceleration : float = 0.15
@export var deacceleration : float  = 0.3
@export var input_multiplier : float = 0.5
@export var gravity_multiplier : float = 1.0

@export_group("control vars")
@export var InputMultiplier : float = 0.85

@export_category("Camera effects var")
@export var max_camera_rotation : float = 10.0
@export var jump_force : float = 4.5



var wall_jump_left : float = 2.0
var wall_jump : bool = false
var current_speed : float
var wall_jump_control_lock : float = 1.5
var player_air_mov_direction

func physics_update(delta : float)-> void:
	Player.update_gravity(delta , gravity_multiplier)
	
	if  Input.is_action_just_pressed("Dash") and Player.can_dash :
		change_state.emit("DashState")
	
	
	if Player.is_on_wall()  and Input.is_action_just_pressed("jump") and wall_jump_left > 0.0:
		if Player.get_last_slide_collision() == null:
			return
		var wall_normal = Player.get_last_slide_collision().get_normal()
		
		if wall_normal.y > abs(0.25): 
			return
		wall_jump = true
		wall_jump_control_lock = 1.5
		Player.wall_jump(wall_normal , Player.wall_jump_retention , jump_force , Player.wall_push_force)
		wall_jump_left -= 1
		return
	
	if Player.valid_wall_run():
		change_state.emit("WallRunState")
		return
	
	Player.apply_air_resistance(delta)
	if wall_jump_control_lock > 0.0:
		wall_jump_control_lock -= delta
	else:
		Player.update_air_movement(player_air_mov_direction ,delta , InputMultiplier , acceleration)
	
func _update(delta : float) -> void:
	var max_speed : float = 11.0
	var vertical_speed = abs(Player.velocity.y)
	var speed_delta = pow(vertical_speed/max_speed ,2)
	speed_delta = clamp(speed_delta , 0.0 , 1.0)
	var rotation_delta = max_camera_rotation * speed_delta
	Player.CameraJuice_Component.rot_pivot_x_rot_amount = rotation_delta

	if Player.is_on_floor():
		change_state.emit("IdleState")
		PlayerAnimation.play("land")
		Player.audio_manager.play_land_sfx()

func exit()-> void:
	wall_jump_control_lock = 1.5
	Player.CameraJuice_Component.rot_pivot_x_rot_amount = 0.0

func enter()->void:
	player_air_mov_direction = Player.transform.basis

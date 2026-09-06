class_name JumpState  extends PlayerMovementState

@export var jump_force : float = 4.5
@export var speed : float = 6.0
@export var acceleration : float = 0.15
@export var deacceleration : float  = 0.25
@export var InputMultiplier : float = 0.85
@export var double_jump : bool = true
@export var gravity_multiplier : float = 1.0
var jump_count : int = 0



var wall_jump_left : float = 2.0
var wall_jump : bool = false
var current_speed : float
var wall_jump_control_lock : float = 1.5

var player_air_mov_direction

func enter()->void:
	#if Player.is_on_wall() and Player.velocity.y < 1.0:
		#wall_jump_control_lock = 1.8
	Player.velocity.y  += jump_force
	PlayerAnimation.play("jump")
	Player.audio_manager.play_jump_sfx()
	current_speed = speed
	player_air_mov_direction = Player.transform.basis

func _update(delta : float) -> void:
	
	if Input.is_action_just_pressed("jump"):
		if Player.vaulter.can_vault():
			change_state.emit("VaultState")
			return
	
	if Player.velocity.y < -5.0 :
		change_state.emit("FallingState")
	
	if Player.is_on_floor()  and Input.is_action_pressed("crouch") and Player.current_horizontal_velocity.length() > Player.slide_threshold_speed and Player.velocity.y <= 0.01 and Input.get_vector("left", "right", "forward", "baackward").length() > 0:
		change_state.emit("SlideState")
		return
	
	if Player.is_on_floor() and Player.velocity.y < 1.0:
		Player.audio_manager.play_land_sfx()
		jump_count = 0    
		change_state.emit("IdleState")
		return
	
	
	
		
func physics_update(delta : float)-> void:
	Player.update_gravity(delta , gravity_multiplier)
	
	if  Input.is_action_just_pressed("Dash") and Player.can_dash :
		change_state.emit("DashState")
	
	if Player.is_on_wall()  and Input.is_action_just_pressed("jump") and wall_jump_left > 0.0 and !Player.vaulter.can_vault():
		if Player.get_last_slide_collision() == null:
			return
		var wall_normal = Player.get_last_slide_collision().get_normal()
		
		if wall_normal.y > abs(0.25): 
			return
		wall_jump = true
		#wall_jump_control_lock = 1.5
		Player.wall_jump(wall_normal , jump_force , Player.wall_jump_retention , Player.wall_push_force)
		wall_jump_left -= 1
		return
	
	if Player.valid_wall_run():
		change_state.emit("WallRunState")
		return
	
	if Input.is_action_just_pressed("jump") and double_jump:
		Player.audio_manager.play_jump_sfx()
		player_air_mov_direction = Player.transform.basis
		#wall_jump_control_lock = 0.0
		Player.velocity.y = jump_force
		double_jump = false
		wall_jump = false
		return
	
	
	
	#if wall_jump_control_lock > 0.0:
		#wall_jump_control_lock -= delta
	
	Player.update_air_movement(player_air_mov_direction , delta , InputMultiplier , acceleration)
	


func exit()-> void:
	#wall_jump_control_lock = 0.0
	PlayerAnimation.play("land")
	double_jump = true
	wall_jump_left = Player.max_wall_jump
	Player.current_coyote_time = Player.coyote_time

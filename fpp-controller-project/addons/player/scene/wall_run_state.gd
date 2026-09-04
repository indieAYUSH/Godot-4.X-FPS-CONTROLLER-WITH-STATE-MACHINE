extends PlayerMovementState
class_name WallRunState

@export_category("Movement vars")
@export var speed : float = 15.0
@export var acceleration : float = 0.15
@export var deacceleration : float  = 0.3
@export var Z_rotation_amount : float = 10.0
@export var gravity_multiplier : float = 1.0

@export_group("wall run vars")
@export var wall_run_time : float = 2.0



var wall_away_sign

var current_wall_run_timer : float


func enter()->void:
	current_wall_run_timer = wall_run_time
	Player.velocity.y = 0.0
	Player.CameraJuice_Component.current_camera_state = Player.CameraJuice_Component.CAMERA_STATE.WALL_RUN
	Player.free_look = true


func physics_update(delta : float)-> void:
	Player.update_gravity(delta , gravity_multiplier)
	
	var wall_collision = Player.get_last_slide_collision()
	if wall_collision == null: 
		change_state.emit("FallingState")
		return
	
	var wall_normal = wall_collision.get_normal()
	
	if abs(wall_normal.y)>0.2:
		change_state.emit("FallingState")
		return
	
	wall_away_sign = -sign(wall_normal.dot(Player.global_transform.basis.x))
	Player.CameraJuice_Component.rot_pivot_manager(Z_rotation_amount*wall_away_sign) 
	
	Player.wall_run(wall_normal , speed , acceleration)
	
	if !Player.is_on_wall():
		change_state.emit("FallingState")
		return
	
	if Player.is_on_floor():
		if Player.velocity.length() > 7.0:
			change_state.emit("SprintState")
			return
		change_state.emit("IdleState")
	if !Input.is_action_pressed("forward"):
		change_state.emit("FallingState")
	
	
	if Input.is_action_just_pressed("jump"):
		Player.wall_jump(wall_normal ,0.0 , Player.wall_jump_retention , Player.wall_push_force)
		change_state.emit("JumpState")
	


func _update(delta : float) -> void:
	current_wall_run_timer -= delta
	if current_wall_run_timer <= 0.0:
		change_state.emit("FallingState")
	
	
func exit()-> void:
	Player.CameraJuice_Component.rot_pivot_manager(0.0)
	Player.CameraJuice_Component.current_camera_state = Player.CameraJuice_Component.CAMERA_STATE.GROUND_MOVEMENT

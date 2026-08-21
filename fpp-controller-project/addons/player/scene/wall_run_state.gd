extends PlayerMovementState
class_name WallRunState

@export_category("Movement vars")
@export var speed : float = 15.0
@export var acceleration : float = 0.15
@export var deacceleration : float  = 0.3
@export var fov_change : float = 8.0
@export var gravity_multiplier : float = 1.0

@export_group("wall run vars")
@export var wall_run_time : float = 2.0




var current_wall_run_timer : float


func enter()->void:
	current_wall_run_timer = wall_run_time
	Player.CameraJuice_Component.rot_pivot_manager(0.0)
	Player.velocity.y = 0.0
	print("enterd wall run")

func physics_update(delta : float)-> void:
	Player.update_gravity(delta , gravity_multiplier)
	Player.update_movement(speed , acceleration , deacceleration)
	
	var wall_collision = Player.get_last_slide_collision()
	
	if wall_collision == null: 
		return
	
	var wall_normal = wall_collision.get_normal(0)
	
	Player.wall_run(wall_normal , speed)
	
	if !Player.is_on_wall() or Player.velocity.length() < Player.wall_run_velocity_threshold:
		change_state.emit("FallingState")
	
	if Input.is_action_just_pressed("jump"):
		Player.wall_jump(wall_normal , 2.0 , Player.wall_jump_retention , Player.wall_push_force)
		change_state.emit("JumpState")

func _update(delta : float) -> void:
	current_wall_run_timer -= delta
	if current_wall_run_timer <= 0.0:
		change_state.emit("FallingState")

func exit()-> void:
	Player.CameraJuice_Component.rot_pivot_manager(0.0)

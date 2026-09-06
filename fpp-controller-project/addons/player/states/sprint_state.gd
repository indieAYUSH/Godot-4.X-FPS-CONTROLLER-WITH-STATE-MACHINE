class_name SprintState   extends PlayerMovementState

@export_category("Movement vars")
@export var speed : float = 11.0
@export var acceleration : float = 10.0
@export var deacceleration : float  = 20.0
@export var fov_change : float = 8.0
@export var gravity_multiplier : float = 1.0


func enter()->void:
	Player.ground_accel = speed*10


func physics_update(delta : float)-> void:
	Player.update_gravity(delta , gravity_multiplier)
	Player.update_movement(speed ,  delta)
	

func _update(delta : float) -> void:
	if Input.is_action_pressed("walk"):
		change_state.emit("WalkState")
		return
	
	if Input.is_action_just_pressed("jump"):
		if Player.vaulter.can_vault():
			change_state.emit("VaultState")
			return
		elif Player.current_coyote_time > 0.0:
			change_state.emit("JumpState")
		return
	
	if Input.is_action_just_pressed("crouch") and Player.is_on_floor():
		change_state.emit("SlideState")
		return
	
	if Player.velocity.y < -3.0 :
		change_state.emit("FallingState")
		return
	
	if  Input.is_action_just_pressed("Dash") and Player.can_dash :
		change_state.emit("DashState")
		return
	
	if Player.velocity.length() < 0.1 :
		change_state.emit("IdleState")
		return
	
func exit()-> void:
	pass
	

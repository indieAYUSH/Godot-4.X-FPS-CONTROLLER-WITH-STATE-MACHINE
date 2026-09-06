class_name IdleState extends PlayerMovementState

@export_category("Movement vars")
@export var speed : float = 7.0
@export var acceleration : float = 10.0
@export var deacceleration : float  = 20.0
@export var gravity_multiplier : float = 1.0


func enter()->void:
	Player.ground_accel = speed*10


func _update(delta):
	if Player.is_on_floor() and Player.velocity.length() > 0.1:
		change_state.emit("SprintState")
		return
	
	if Input.is_action_pressed("crouch") and Player.is_on_floor():
		change_state.emit("CrouchState")
		return
	
	if Input.is_action_just_pressed("jump"):
		if Player.vaulter.can_vault():
			change_state.emit("VaultState")
			return
		elif Player.current_coyote_time > 0.0:
			change_state.emit("JumpState")
		return
	
	if !Player.is_on_floor():
		change_state.emit("FallingState")
		return


func physics_update(delta : float)-> void:
	Player.update_gravity(delta , gravity_multiplier)
	Player.update_movement(speed ,  delta)
	

func _input_update(event ):
	if  event.is_action_pressed("Dash") and Player.can_dash :
		change_state.emit("DashState")
		return

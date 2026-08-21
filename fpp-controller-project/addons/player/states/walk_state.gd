class_name WalkState extends PlayerMovementState

@export_category("Movement vars")
@export var speed : float = 7.5
@export var acceleration : float = 0.15
@export var deacceleration : float  = 0.3
@export var gravity_multiplier : float = 1.0

func _update(delta:float):
	
	
	if !Input.is_action_pressed("walk"):
		change_state.emit("SprintState")
	
	if Input.is_action_pressed("crouch") :
		change_state.emit("CrouchState")
	
	if Input.is_action_just_pressed("jump") and Player.is_on_floor():
		change_state.emit("JumpState")
	
	if Player.velocity.y < -3.0 :
		change_state.emit("FallingState")
	if  Input.is_action_just_pressed("Dash") and Player.can_dash :
		change_state.emit("DashState")
	


func physics_update(delta : float)-> void:
	Player.update_movement(speed , acceleration , deacceleration)
	Player.update_gravity(delta , gravity_multiplier)

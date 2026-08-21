class_name SprintState   extends PlayerMovementState

@export_category("Movement vars")
@export var speed : float = 11.0
@export var acceleration : float = 0.15
@export var deacceleration : float  = 0.3
@export var fov_change : float = 8.0
@export var gravity_multiplier : float = 1.0


func enter()->void:
	pass


func physics_update(delta : float)-> void:
	Player.update_gravity(delta , gravity_multiplier)
	Player.update_movement(speed , acceleration , deacceleration)
	

func _update(delta : float) -> void:
	if Input.is_action_pressed("walk"):
		change_state.emit("WalkState")
		
	if Input.is_action_just_pressed("jump") and Player.is_on_floor():
		change_state.emit("JumpState")
	
	if Input.is_action_just_pressed("crouch") and Player.is_on_floor():
		change_state.emit("SlideState")
	
	if Player.velocity.y < -3.0 :
		change_state.emit("FallingState")
	
	if  Input.is_action_just_pressed("Dash") and Player.can_dash :
		change_state.emit("DashState")
	if Player.velocity.length() < 0.1 :
		change_state.emit("IdleState")
		
func exit()-> void:
	pass
	

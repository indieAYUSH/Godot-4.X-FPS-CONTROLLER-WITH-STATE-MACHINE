class_name JumpState  extends PlayerMovementState

@export var jump_force : float = 4.5
@export var wall_push_force : float = 10.0
@export var speed : float = 6.0
@export var acceleration : float = 0.15
@export var deacceleration : float  = 0.25
@export var InputMultiplier : float = 0.85
@export var double_jump : bool = true
@export var gravity_multiplier : float = 1.0
var jump_count : int = 0


func enter()->void:
	Player.velocity.y += jump_force
	PlayerAnimation.play("jump")
	jump_count += 1

func _update(delta : float) -> void:
	
	if Player.velocity.y < -5.0 :
		change_state.emit("FallingState")
	
	
	if Player.is_on_floor():
		jump_count = 0
		change_state.emit("IdleState")

	
	
		
func physics_update(delta : float)-> void:
	Player.update_gravity(delta , gravity_multiplier)
	Player.update_movement(speed*InputMultiplier , acceleration , deacceleration)
	
	if  Input.is_action_just_pressed("Dash") and Player.can_dash :
		change_state.emit("DashState")
	
	#if Player.is_on_wall() and Input.is_action_just_pressed("jump"):
		#
		#if Player.get_last_slide_collision() == null:
			#return
		#
		#var wall_normal = Player.get_last_slide_collision().get_normal()
		#Player.velocity = wall_push_force*wall_normal
		#Player.velocity.y = jump_force
	
	if Player.is_on_wall() and Input.is_action_pressed("sprint"):
		change_state.emit("WallRunState")


func exit()-> void:
	PlayerAnimation.play("land")

func _input_update(event):
	if event.is_action_pressed("jump") and jump_count < 2 and double_jump:
		Player.velocity.y += jump_force
		jump_count += 1

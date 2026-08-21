class_name SlideState extends PlayerMovementState

@export_category("Movement vars")
@export var sliding_speed : float = 18.0
@export var sliding_timer_max : float = 1.2
@export var acceleration : float = 0.15
@export var deacceleration : float = 0.3
@export var gravity_multiplier : float = 1.0
var sliding_timer
var slide_direction 
@export var lerp_Speed : float = 10.0

@export_category("camera category")
@export var added_camera_fov :float = 15.0



func enter()->void:
	Player.free_look = true
	sliding_timer = sliding_timer_max
	Player.crouch()
	Player.audio_manager.play_slide_sfx()
	Player.CameraJuice_Component.rot_pivot_manager(5.0)
	slide_direction = Player.transform.basis


func physics_update(delta : float)-> void:
	sliding_timer-= delta
	Player.update_gravity(delta , gravity_multiplier)
	Player.update_slide_movement(slide_direction , (sliding_timer+0.4)*sliding_speed , acceleration , deacceleration)
	
	if sliding_timer <= 0.0:
		if Player.input_dir != Vector2.ZERO:
			change_state.emit("WalkState")
		else :
			change_state.emit("IdleState")
	if Input.is_action_just_pressed("jump"):
		change_state.emit("JumpState")
	
	if Player.is_on_wall():
		change_state.emit("IdleState")



func exit()-> void:
	Player.uncrouch()
	Player.CameraJuice_Component.rot_pivot_manager(0.0)
	Player.audio_manager.stop_audio_player("slide")
	Player.audio_manager.stop_audio_player("slideloop")

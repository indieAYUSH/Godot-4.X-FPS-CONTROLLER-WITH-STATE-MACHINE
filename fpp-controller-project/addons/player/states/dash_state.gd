class_name DashState
extends PlayerMovementState

@export_category("DASH MOVEMENET VAR")
@export var max_dash_time : float = 0.3
@export var dash_speed : float = 38.0
#@export var acceleration : float = 0.95
#@export var deacceleration : float = 10.0
@export var gravity_multiplier : float = 1.0


@export_category("Camera var")
@export var camera : Camera3D
@export var added_camer_fov : float = 15.0

@export_category("other var")
@export var DashCoolDown : float = 5.0
@export var DashCoolDownTimer : Timer

#
var dash_timer
var dir

func enter()->void:
	if Player.can_dash:
		dash_timer = max_dash_time
		var forward_dir : Vector3 = -camera.global_transform.basis.z
		dir = forward_dir
		DashCoolDownTimer.wait_time = DashCoolDown
		DashCoolDownTimer.start()
		Player.can_dash = false
		
	else:
		dash_timer = 0.0
	Player.CameraJuice_Component.fov_manager(added_camer_fov)

func _update(delta : float) -> void:
	dash_timer -= delta
	if dash_timer <= 0.0:
		change_state.emit("IdleState")

func physics_update(delta : float)-> void:
	Player.update_gravity(delta , gravity_multiplier)
	Player.dash(dir , dash_speed)


func exit()-> void:
	Player.CameraJuice_Component.fov_manager(-added_camer_fov)
	Player.velocity = Vector3.ZERO

func _on_dash_cool_down_timeout():
	Player.can_dash = true

class_name CameraControllerComponent
extends Node3D

@export_category("Refrences")
@export var mouse_controller_component : MouseControllerComponent
@export var Player_controller : PlayerController


@export_category("Camera_settings")
@export_range(-90.0 , -60.0) var min_tilt : int = -90
@export_range(60.0 , 90.0) var max_tilt : int = 90

var crouch_offset : = 0.0
var crouch_speed : float = 4.0

const Default_Hieght :float = 0.6

var _rotation : Vector3
var free_look_rotation : Vector3


func _update_rotation(input:Vector2)-> void :
	if Player_controller.freezed:
		return
	_rotation.x += input.y
	_rotation.y += input.x
	
	_rotation.x = clamp( _rotation.x , deg_to_rad(min_tilt) , deg_to_rad(max_tilt))
	_rotation.z = 0.0
	
	
	
	
	var camera_rotation  = Vector3(_rotation.x , 0.0 , 0.0)
	var player_rotation = Vector3(0.0 , _rotation.y , 0.0)
	var _free_look_rot = Vector3(0.0 , free_look_rotation.y , 0.0)
	
	
	transform.basis = Basis.from_euler(camera_rotation)

	Player_controller._update_rotation(player_rotation)

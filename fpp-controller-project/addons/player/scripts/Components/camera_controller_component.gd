class_name CameraControllerComponent
extends Node3D

@export_category("Refrences")
@export var mouse_controller_component : MouseControllerComponent
@export var Player_controller : PlayerController


@export_category("Camera_settings")
@export_range(-90.0 , -60.0) var min_tilt : int = -90
@export_range(60.0 , 90.0) var max_tilt : int = 90



const Default_Hieght :float = 0.6

var _rotation : Vector3


@export_group("step smoothing")
@export var _smoothing_speed : float = 8.0

var _target_height : float
var _step_smoothing : bool = false
var _offset_height : float

func _update_rotation(input:Vector2)-> void :
	if Player_controller.freezed:
		return
	_rotation.x += input.y
	_rotation.y += input.x
	
	_rotation.x = clamp( _rotation.x , deg_to_rad(min_tilt) , deg_to_rad(max_tilt))
	_rotation.z = 0.0
	
	
	
	
	var camera_rotation  = Vector3(_rotation.x , 0.0 , 0.0)
	var player_rotation = Vector3(0.0 , _rotation.y , 0.0)
	
	transform.basis = Basis.from_euler(camera_rotation)

	Player_controller._update_rotation(player_rotation)

func _smooth_step(height_change : float):
	_target_height -= height_change
	_step_smoothing = true

func _ready() -> void:
	_offset_height = position.y

func _process(delta: float) -> void:
	if _step_smoothing:
		_target_height = lerp(_target_height , 0.0 , delta * _smoothing_speed)
		if abs(_target_height) < 0.01:
			_target_height  = 0.0
			_step_smoothing = false
		position.y = _offset_height + _target_height

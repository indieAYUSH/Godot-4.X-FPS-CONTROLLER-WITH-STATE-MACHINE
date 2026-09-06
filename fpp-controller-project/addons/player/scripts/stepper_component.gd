extends Node
class_name StepperComponent

@export var player_controller : PlayerController
@export var surface_threshold : float = 0.25
@export var max_step_hieght : float = 0.5





const FEET_BUFFER  : float  = 0.05
const MIN_STEP_HEIGHT : float = 0.1
const MIN_STEP_DOT_VAL  : float = 0.5
const MIN_MOV_DIR_LENGTH : float = 0.1


func _ready() -> void:
	if player_controller == null:
		player_controller = owner as PlayerController

func _handle_step_climbing(delta : float):
	for i in player_controller.get_slide_collision_count():
		var collision  = player_controller.get_slide_collision(i)
		if collision == null:
			return
		if ! _is_vertical_surface(collision):
			return
		var step_height = _measure_step_height(collision)
		if step_height > MIN_STEP_HEIGHT and step_height <= max_step_hieght:
			player_controller.global_position.y += step_height
			player_controller.camera_controller._smooth_step(step_height)
			


func check_surface_normal(collsion : KinematicCollision3D) -> bool:
	var collision_point = collsion.get_position()
	var feet_pos : Vector3 = _get_player_feet_position()
	collision_point.y = feet_pos.y
	var ray_cast_result  = player_controller.ray_cast_component._cast_ray(feet_pos , collision_point)
	if ray_cast_result and abs(ray_cast_result.normal.y) <= surface_threshold:
		return true and _is_valid_step(ray_cast_result.normal)
	return false

func _is_vertical_surface(collision : KinematicCollision3D) -> bool:
	var normal = collision.get_normal()
	if abs(normal.y) <= surface_threshold:
		return true and _is_valid_step(normal)
	return check_surface_normal(collision)

func _get_player_feet_position() -> Vector3:
	var feet_pos : Vector3 = player_controller.global_position
	feet_pos.y += FEET_BUFFER
	return feet_pos

func _measure_step_height(collision : KinematicCollision3D)->float:
	var collision_point = collision.get_position()
	var head_cast_point = collision_point
	head_cast_point.y += 2.0
	var result = player_controller.ray_cast_component._cast_ray(head_cast_point  ,collision_point)
	if result:
		return abs(result.position.y - player_controller.global_position.y)
	return 0.0

func _is_valid_step(normal : Vector3) -> bool:
	var player_movement_dir = (player_controller.transform*Vector3(player_controller.input_dir.x , 0.0 , player_controller.input_dir.y))
	if player_movement_dir.length() > MIN_MOV_DIR_LENGTH:
		player_movement_dir = player_movement_dir.normalized()
		var step_dot = player_movement_dir.dot(-normal)
		return step_dot > MIN_STEP_DOT_VAL
	return false

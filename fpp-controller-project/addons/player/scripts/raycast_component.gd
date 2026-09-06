extends Node
class_name RaycastComponent

#made for casting ray for a obj like her player so i will automatically exlude player and use it collision mask

@export var parent : CharacterBody3D

func _ready() -> void:
	if !parent:
		parent = owner

func _cast_ray(start_point : Vector3 , end_point : Vector3 ) -> Dictionary:
	var space_state = parent.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(start_point , end_point)
	query.exclude = [parent.get_rid()]
	query.collision_mask = parent.collision_mask
	var result = space_state.intersect_ray(query)
	return result
	

class_name Vaulter
extends Node3D


@export var vault_cast : RayCast3D
@export  var ray_cast_component : RaycastComponent

var vault_point : Vector3




func can_vault() -> bool:
	if vault_cast.is_colliding():
		vault_point = vault_cast.get_collision_point()
		print(vault_cast.get_collider())
		var end_check_point  : Vector3 = vault_point 
		end_check_point.y += 2.05
		var result = ray_cast_component._cast_ray(vault_point , end_check_point)
		print(vault_cast)
		return !result
	
	return false


class_name PhysicsInteractionComponent
extends Node

@export var enabled : bool

@export_category("Rerences")
@export var controller_body: CharacterBody3D

@export_category("Variables")
@export var max_applied_force : float = 10.0

func _ready() -> void:
	controller_body = owner

func _physics_process(delta):
	if not enabled or not controller_body:
		return

	if controller_body.get_slide_collision_count() > 0:
		var collision = controller_body.get_last_slide_collision()
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			var normal = -collision.get_normal()
			var speed = clamp(controller_body.velocity.length(), 1.0, 5.0) # limit impulse
			var impulse_pos = collision.get_position() - collision.get_collider().global_position
			collider.apply_impulse(max_applied_force * speed * normal, impulse_pos)

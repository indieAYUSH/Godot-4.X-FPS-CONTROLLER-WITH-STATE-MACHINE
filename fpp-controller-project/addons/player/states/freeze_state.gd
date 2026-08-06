extends PlayerMovementState
class_name FreezeState

@export_category("Movement vars")
@export var speed : float = 0.0
@export var acceleration : float = 0.0
@export var deacceleration : float  = 0.0
@export var gravity_multiplier : float = 1.0

func _ready():
	pass
	#Player.unfreezeplayer.connect(unfreeze)

func enter()->void:
	Player.freezed = true

func physics_update(delta : float)-> void:
	Player.update_movement(speed , acceleration , deacceleration)
	Player.update_gravity(delta , gravity_multiplier)

func exit()-> void:
	Player.freezed = false


func unfreeze() -> void:
	change_state.emit("IdleState")

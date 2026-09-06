class_name VaultState
extends PlayerMovementState

var last_vel

func enter()->void:
	Player.velocity.y = 0
	PlayerAnimation.play("vault")
	var ledge_p = Player.vaulter.vault_point
	var forw = -Player.global_transform.basis.z
	var destination  = ledge_p + (forw *1.3)
	var start_p = Player.global_position
	var mid = start_p.lerp(destination , 0.45)  + Vector3(0.0 , 0.5 , 0.0)
	var end = destination + Vector3(0.0 , 0.54 , 0.0)
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(Player._vault_breeze.bind(start_p , mid , end) , 0.0 , 1.0 , Player.vault_time)
	tween.tween_callback(state_change_callable)
	


func state_change_callable():
	change_state.emit("FallingState")

func exit()-> void:
	Player.vault_timer = Player.vault_time
	

class_name AudioManager extends Node3D


@export var smoothing_sped : float = 12.0

@export_group("Movement vars")
@export var bob_frequency : float
@export var bob_amplitude : float
@export var bob_smoothing : float
@export var min_speed : float = 6.0
@export var max_speed : float = 16.0

@export_group("ground _ movement")
@export var max_pitch : float = 1.4
@export var min_pitch : float = 0.8
@export var min_volume : float = -3.0
@export var max_volume : float = 7.0

@export_group("air_movement")
@export var air_max_pitch : float = 1.4
@export var air_min_pitch : float = 0.8
@export var air_min_volume : float = -3.0
@export var air_max_volume : float = 10.0

var cycle_threshold : float
var current_bob_value : float
var current_cycle_frequency : float
var current_cycle_amplitude : float



@export_group("sounds(variable)")
@export var surface_movement_soundfx : Dictionary[String , AudioStream]
@export var land_audio_container : Dictionary[String , AudioStream]


@export_group("fixed_movement_sound")
@export var jump_audio : AudioStream
@export var crouch_audio : AudioStream
@export var uncrouch_audio : AudioStream
@export var slide_audio : AudioStream
@export var slide_audio_loop : AudioStream
@export var vault_audio : AudioStream

@export_category("Audio player Refrences")
@export var movement_audio_player : AudioStreamPlayer3D
@export var crouch_audio_player : AudioStreamPlayer3D
@export var uncrouch_audio_player : AudioStreamPlayer3D
@export var jump_audio_player : AudioStreamPlayer3D
@export var land_audio_player : AudioStreamPlayer3D
@export var slide_audio_player : AudioStreamPlayer3D
@export var vault_audio_player : AudioStreamPlayer3D

@export_category("refrences")
@export var player_controller : PlayerController
@export_group("ray cast")
@export var surface_checker_cast : RayCast3D

var current_surface_name : String
var can_play_movement_sound : bool = false


var current_movement_audio : AudioStream
var current_landing_audio : AudioStream
var current_jump_sfx : AudioStream
var current_walrun_sfx : AudioStream
var current_sliding_sfx : AudioStream
var current_vault_audio : AudioStream

var cycle_sin : float

func _ready() -> void:
	if player_controller == null:
		player_controller = owner
	max_speed = player_controller.max_speed
	
	surface_checker_cast.add_exception(player_controller)
	
	current_jump_sfx = jump_audio
	current_landing_audio = land_audio_container["default"]
	current_movement_audio = surface_movement_soundfx["default"]
	current_sliding_sfx = slide_audio
	current_vault_audio = vault_audio
	
	crouch_audio_player.stream = crouch_audio
	uncrouch_audio_player.stream = uncrouch_audio
	movement_audio_player.stream = current_movement_audio
	land_audio_player.stream = current_landing_audio
	jump_audio_player.stream = current_jump_sfx
	slide_audio_player.stream = slide_audio
	vault_audio_player.stream = current_vault_audio


func _physics_process(delta: float) -> void:
	var surface_collider
	if surface_checker_cast.is_colliding():
		surface_collider = surface_checker_cast.get_collider()
	elif player_controller.is_on_wall():
		surface_collider = player_controller.get_last_slide_collision().get_collider()
	if !surface_collider: 
		return
	var surface_group = surface_collider.get_groups()
	
	if surface_group.is_empty():
		return
	
	var surface_name = surface_group[0]
	if current_surface_name != surface_name:
		current_surface_name = surface_name
		var movement_audio = surface_movement_soundfx.get(current_surface_name)
		if movement_audio:
			current_movement_audio = surface_movement_soundfx[current_surface_name]
			movement_audio_player.stream = current_movement_audio
		var land_audio = land_audio_container.get(current_surface_name)
		if land_audio:
			current_landing_audio = land_audio_container[current_surface_name]
			land_audio_player.stream = current_landing_audio

#Wwwd
func _process(delta: float) -> void:
	calculate_walk_cycle(delta)
	#dynamic_pitch_volume(delta)

func calculate_walk_cycle(delta : float) ->void:
	var valid_surface_movement : bool = (player_controller.is_on_floor() or (player_controller.is_on_wall() and player_controller.player_statemachine.current_state.name == "WallRunState"))
	var bob_multiplier = float(player_controller.CameraJuice_Component._can_headbob())
	var speed = min(player_controller.velocity.length() , max_speed)
	if speed > 0.5 and valid_surface_movement:
		current_cycle_frequency += bob_frequency*delta*speed
		current_cycle_amplitude = bob_frequency*speed
		cycle_sin =  (sin(current_cycle_frequency)*current_cycle_amplitude - 0.02)*bob_multiplier
		current_bob_value = lerp(current_bob_value , cycle_sin/2.0 , delta*bob_smoothing)
		cycle_threshold = -bob_amplitude + 0.09   ## i got it working on this value
		if current_bob_value > cycle_threshold:
			can_play_movement_sound = true
		elif current_bob_value < cycle_threshold and can_play_movement_sound:
			play_movement_sfx()
			can_play_movement_sound = false



func play_crouch_sfx() -> void:
	crouch_audio_player.play()

func play_uncrouch_sfx() -> void:
	uncrouch_audio_player.play()

func play_jump_sfx() -> void:
	jump_audio_player.play()

func play_land_sfx() -> void:
	land_audio_player.play()

func play_slide_sfx() -> void:
	slide_audio_player.play()

func play_slide_sfx_loop(delta) -> void:
	pass

func stop_audio_player(_node_name : String):
	var audio_player : AudioStreamPlayer3D = get_node(_node_name)
	if audio_player.playing:
		audio_player.stop()


func play_movement_sfx() -> void:
	movement_audio_player.play()

func dynamic_pitch_volume(delta : float) ->void:
	var current_speed = player_controller.velocity.length()
	
	
	var speed_ratio = (current_speed/max_speed)
	var target_pitch = speed_ratio*max_pitch
	var target_volume 
	
	if player_controller.velocity.y < -4.0:
		var vel_ratio = abs(player_controller.velocity.y/10.0)
		vel_ratio = clamp(vel_ratio , 0.0 , 1.0)
		var target_landing_volume = vel_ratio*air_max_volume
		land_audio_player.volume_db = lerp(land_audio_player.volume_db , target_landing_volume , smoothing_sped*delta)
		land_audio_player.pitch_scale = air_max_pitch
	else:
		land_audio_player.pitch_scale = air_min_pitch
		
	
	movement_audio_player.pitch_scale = clamp(remap(current_speed , min_speed , max_speed , 0.85 , 1.2 ) , 0.85 , 1.2)


func play_vault_audio():
	vault_audio_player.play()

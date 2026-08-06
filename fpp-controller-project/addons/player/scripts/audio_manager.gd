class_name AudioManager extends Node3D



@export_group("Movement vars")
@export var bob_frequency : float
@export var bob_amplitude : float
@export var bob_smoothing : float

var cycle_threshold : float
var current_bob_value : float
var current_cycle_frequency : float
var current_cycle_amplitude : float



@export_category("sounds")
@export var walking_footsteps_sound_placeholder : AudioStream
@export var crouch : AudioStream
@export var uncrouch : AudioStream
@export var jump : AudioStream
@export var land : AudioStream
@export var slide : AudioStream


@export_category("Audio player Refrences")
@export var movement_audio_player : AudioStreamPlayer3D
@export var crouch_audio_player : AudioStreamPlayer3D
@export var uncrouch_audio_player : AudioStreamPlayer3D
@export var jump_audio_player : AudioStreamPlayer3D
@export var land_audio_player : AudioStreamPlayer3D
@export var slide_audio_player : AudioStreamPlayer3D

@export_category("refrences")
@export var player_controller : PlayerController
@export_group("ray cast")
@export var surface_checker_cast : RayCast3D

var current_surface_name : String
var can_play_movement_sound : bool = false


var current_floor_movement_audio : AudioStream
var current_landing_audio : AudioStream
var current_jump_sfx : AudioStream
var current_walrun_sfx : AudioStream
var current_sliding_sfx : AudioStream

var cycle_sin : float

func _ready() -> void:
	if player_controller == null:
		player_controller = owner

func _physics_process(delta: float) -> void:
	if surface_checker_cast.is_colliding():
		var surface_collider = surface_checker_cast.get_collider()
		if !surface_collider: 
			return
		var surface_group = surface_collider.get_groups()
		
		if surface_group.is_empty():
			return
		
		var surface_name = surface_group[0]
		if current_surface_name != surface_name:
			current_surface_name = surface_name
			

#Wwwd
func _process(delta: float) -> void:
	calculate_walk_cycle(delta)

func calculate_walk_cycle(delta : float) ->void:
	var bob_multiplier = float(player_controller.CameraJuice_Component._can_headbob())
	var speed = player_controller.velocity.length()
	if speed > 0.5 and player_controller.is_on_floor() :
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

func play_movement_sfx() -> void:
	movement_audio_player.play()

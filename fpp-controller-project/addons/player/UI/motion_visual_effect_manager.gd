extends Control
class_name MotionVisualEffectManager


@export_category("player vars")
@export var player_controller : PlayerController
@export var min_speed : float = 5.0
@export var max_speed : float = 21.0


@export_category("Post processgin parms")
@export_group("vignette_params")
@export var min_vgIntensity : float = 0.0
@export var max_vgIntensity : float = 0.8
@export var min_vg_opacity : float = 0.0
@export var max_vg_opacity : float = 0.7
@export var vg_rect : ColorRect

@export_group("radial blur shader")
@export var min_blur_power : float = 0.0
@export var max_blur_power : float = 0.012
@export var rblur_rect : ColorRect

@export_category("juice vars")
@export var smoothing_sped : float = 8.0

var current_vg_opacitu : float
var current_vg_intensity : float
var current_rblur_power : float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player_controller == null:
		player_controller = owner as PlayerController


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var speed : float = player_controller.velocity.length()
	
	var desired_rblur : float = clamp(remap(speed , min_speed , max_speed , min_blur_power , max_blur_power) , min_blur_power , max_blur_power)
	var desired_vg_intensity : float  = clamp(remap(speed , min_speed , max_speed , min_vgIntensity , max_vgIntensity ) , min_vgIntensity , max_vgIntensity)
	var dsired_vg_opacity : float = clamp(remap(speed , min_speed , max_speed , min_vg_opacity , max_vgIntensity ) , min_vg_opacity , max_vg_opacity)
	
	current_rblur_power = lerp(current_rblur_power , desired_rblur , smoothing_sped*delta)
	current_vg_intensity = lerp(current_vg_intensity , desired_vg_intensity , smoothing_sped*delta)
	current_vg_opacitu = lerp(current_vg_opacitu , dsired_vg_opacity , smoothing_sped*delta)
	
	
	rblur_rect.material.set_shader_parameter("blur_power" , current_rblur_power)
	vg_rect.material.set_shader_parameter("vignette_intensity" , current_vg_intensity)
	vg_rect.material.set_shader_parameter("vignette_opacity" , current_vg_opacitu)
	

extends Node3D
class_name item_holder

#Refrences
@onready var camera_3d = %Camera3D
@onready var pos_place_holder: Node3D = $"../../../../../../../pos_place_holder"
@onready var pos_place_holder_2: Node3D = $"../../../../../../../pos_place_holder2"


@export_group("context_menu_vars")
@export var context_override : bool
@export var input_prompt_override : String
@export var input_icon : Texture2D
@export_group("Refrences")
@export var item_resource  : Array[HoldAbleItemResource]

var has_item : bool  = false
var can_hold_item : bool = true
var item
var item_list = {}


var current_item : HoldAbleItemResource

func _ready():
	for i in item_resource:
		item_list[i.name] = i


func pickup_object(_name : String):
	if has_item:
		remove_item(true , _name)
	else :
		add_item(_name)


func add_item(_name : String ):
	print(_name)
	
	if !can_hold_item:
		return
	if !item_list.has(_name):
		push_error("Item '%s' not found in item_list" % _name)
		return
	current_item = item_list[_name]

	if !current_item:
		return
	
	
	var scene = current_item.scene.instantiate()
	add_child(scene)
	position = current_item.position
	scale = current_item.scale
	rotation = Vector3(deg_to_rad(current_item.rotation.x) , deg_to_rad(current_item.rotation.y) , deg_to_rad(current_item.rotation.z))
	item = scene
	has_item = true
	MessageBus.UpdateContextMenu.emit(context_override , input_icon , input_prompt_override)

func remove_item(reload_item : bool , _item_name : String):
	if !item:
		return
		
		#ITEM DROP
	var d_s : RigidBody3D  = current_item.Droppable_scene.instantiate()
	get_tree().current_scene.add_child(d_s)
	d_s.global_position = pos_place_holder_2.global_position
	d_s.linear_velocity = ((pos_place_holder.global_position - pos_place_holder_2.global_position).normalized() * 7.0)
	item.queue_free()
	
	#CLEANUP
	current_item = null
	has_item = false
	MessageBus.ResetContextMenu.emit()
	if reload_item:
		add_item(_item_name)

#
func _input(event):
	if Input.is_action_just_pressed("right_action_button"):
		if has_item:
			remove_item(false , "")

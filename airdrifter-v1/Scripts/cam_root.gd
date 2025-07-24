extends Node3D

var cam_rot_h = 0.0
var cam_rot_v = 0.0
var max_v_rotation = 75.0
var min_v_rotation = -55.0
## Camera Sensitivity
@export var sensitivity = 0.1
var h_accel = 10
var v_accel = 10

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("free_look") and event is InputEventMouseMotion:
		cam_rot_h += -event.relative.x * sensitivity
		cam_rot_v += event.relative.y * sensitivity
		


func _process(delta: float) -> void:
	
	if not Input.is_action_pressed("free_look"):
		cam_rot_h = 0.0
		cam_rot_v = 12.5
	else:
		#rotation.x = 0
		rotation.x = get_parent_node_3d().rotation.x * -1.0
	
	top_level
	
	cam_rot_v = clamp(cam_rot_v, min_v_rotation, max_v_rotation)
	
	$Horz.rotation_degrees.y = lerp($Horz.rotation_degrees.y, cam_rot_h, delta * h_accel)
	$Horz/Vert.rotation_degrees.x = lerp($Horz/Vert.rotation_degrees.x, cam_rot_v, delta * v_accel)
	
	global_position = get_parent().global_position


## I want 

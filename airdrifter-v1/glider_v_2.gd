extends CharacterBody3D

var GRAVITY = Vector3(0, -9.8, 0)
var vertical_velocity: float
@export var gravityCurve: Curve
@export var forward_velocity: Vector3
@export var debug_velo: Vector3
@export var drag_const: float = 0.5

func _physics_process(delta: float) -> void:
	#Gravity effecting the glider
	velocity += GRAVITY * delta
	vertical_velocity = velocity.y
	
	# FInding forward direction based on where the glider is pointed
	var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	var forward_dir: Vector3 = (global_transform.basis * forward_local_axis).normalized()
	
	forward_velocity = forward_dir * (-1.0 * vertical_velocity) * 0.1
	forward_velocity -= induce_drag(forward_velocity)
	velocity += forward_velocity
	velocity += induce_lift(velocity) * delta
	#velocity -= induce_drag(velocity) * delta
	move_and_slide()
	
	debug_velo = velocity

func induce_lift(velo: Vector3) -> Vector3:
	var up_axis: Vector3 = Vector3(0, 1, 0)
	var upward_dir: Vector3 = (global_transform.basis * up_axis).normalized()
	return (upward_dir * velo.length())

func induce_drag(velo: Vector3) -> Vector3:
	return 0.5 * velo * velo * drag_const * -1.0
	

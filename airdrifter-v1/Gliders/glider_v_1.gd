extends RigidBody3D

@export var lift_force = 0.5
@export var drag_constant = 0.3
@export var use_this_cam = false;
@export var drag: Vector3

var vertical_velocity: float	# The Y component of the glider's travel
@export var forward_velocity: Vector3	# The direction the glider will go

func _ready() -> void:
	if use_this_cam:
		$"3rdPerCamera".make_current()
	else:
		$"3rdPerCamera".queue_free()
	
	forward_velocity = Vector3.ZERO

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Calculating vertical velocity
	vertical_velocity = state.linear_velocity.y
	
	# Caluculating forward velocity's DIRECTION
	var forward_local_axis: Vector3 = Vector3(0, 0, 1)
	var forward_dir: Vector3 = (global_transform.basis * forward_local_axis).normalized()
	
	# Adding vertical speed (altitude change) to forward velocity
	forward_velocity = forward_dir * (-1.0 * vertical_velocity) * 0.1
	calculate_drag()
	
	# adding forward velocity value to Physics object's linear velocity
	# TODO: With this implementation, when the plane points straight down, the speed doubles EVERY FRAME
	# FIX: with this implementation, forward velocity is treated like ACCELERATION
	state.linear_velocity += forward_velocity
	
	caluclate_lift(state)
	
	#state.linear_velocity = state.linear_velocity.limit_length(75.0)

func caluclate_lift(state: PhysicsDirectBodyState3D) -> void:
	# Get the Forward Velocity's size
	var fv = forward_velocity.length()
	var lift = fv * lift_force
	
	# Find the UP direction in local glider space
	var up_local_axis: Vector3 = Vector3(0, 1, 0)
	var up_dir: Vector3 = (global_transform.basis * up_local_axis).normalized()
	state.linear_velocity += up_dir * lift
	

func calculate_drag() -> void:
	# Calculate Drag Vector 
	drag = 0.5 * forward_velocity * forward_velocity * drag_constant
	
	# Subtract drag vector from forward velocity vector
	forward_velocity -= drag
	
	
	
	

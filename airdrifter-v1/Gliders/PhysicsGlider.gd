extends RigidBody3D

@export var liftForce: float
@export var use_this_cam: bool = false

func _ready() -> void:
	if use_this_cam:
		$"3rdPerCamera".make_current()
	else:
		$"3rdPerCamera".queue_free()
	

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Adding Lift (effected by horizontal velocity)
	state.linear_velocity += calculate_lift(state)
	
	var vertical_velocity = linear_velocity.y
	
	if vertical_velocity < 0:
		var forward_vector = (global_transform.basis * Vector3(0, 0, 1)).normalized()
		forward_vector *= vertical_velocity * -0.1
		state.linear_velocity += forward_vector.limit_length(5)
	

func calculate_lift(state: PhysicsDirectBodyState3D) -> Vector3:
	# Finding Local Up Direction
	var up_vector = (global_transform.basis * Vector3(0, 1, 0)).normalized()
	# Finding Horizontal (X and Z) components of linear velocity
	var horizontal_velocity = state.linear_velocity
	horizontal_velocity.y = 0.0
	
	# Calculating lift based on horizontal velocity
	var lift = up_vector *  horizontal_velocity.length() * 0.01
	return lift.limit_length(50)

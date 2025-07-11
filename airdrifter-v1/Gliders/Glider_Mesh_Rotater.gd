extends Node3D

var parent_glider: RigidBody3D
@export var rotation_curve: Curve

func _ready() -> void:
	parent_glider = get_parent_node_3d()

func _process(delta: float) -> void:
	rotation.z = deg_to_rad(rotation_curve.sample(rad_to_deg(parent_glider.angular_velocity.y)))
	#print(rotation_curve.sample(parent_glider.angular_velocity.y))
	#print(rotation.z)

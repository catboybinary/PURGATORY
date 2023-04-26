@tool
extends CollisionShape3D

@export_group("Collider")
@export var height : float
@export_range(0.1, 20, 0.1) var radius : float
@export var sides_count = 3
@export_group("Chamfer")
@export_range(1, 89, 1) var upper_angle = 45
@export_range(0.1, 20, 0.05) var upper_radius : float
@export_range(1, 89, 1) var lower_angle = 45
@export_range(0.1, 20, 0.05) var lower_radius : float
@export_group("IN EDITOR")
@export var start = true

func _process(delta: float):
	if start:
		var upper_height = tan(deg_to_rad(upper_angle))*(radius-upper_radius)
		var lower_height = tan(deg_to_rad(lower_angle))*(radius-lower_radius)
		shape = ConvexPolygonShape3D.new()
		var points : PackedVector3Array
		for i in range(sides_count):
			var angle : float = deg_to_rad(i*(360/sides_count))
			points.append(Vector3(lower_radius*cos(angle),0,lower_radius*sin(angle)))
			points.append(Vector3(radius*cos(angle),lower_height,radius*sin(angle)))
			points.append(Vector3(radius*cos(angle),height-upper_height,radius*sin(angle)))
			points.append(Vector3(upper_radius*cos(angle),height,upper_radius*sin(angle)))
			
		shape.points = points	
		start = false 
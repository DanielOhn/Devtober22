extends KinematicBody

var velocity = Vector3.ZERO
const speed = 15
const friction = 80

onready var rig : Position3D = $CameraRig
onready var camera : Camera = $CameraRig/Camera
onready var cursor : CSGMesh = $Cursor
onready var primary_ability : CollisionShape = $Front/PrimaryHitbox/CollisionShape

export var Projectile : PackedScene

onready var primary_attackrate : Timer = $PrimaryAttackrate
onready var secondary_attackrate : Timer = $SecondaryAttackrate
onready var primary_attack : MeshInstance = $Front/PrimaryHitbox/CollisionShape/MeshInstance

func _ready():
	rig.set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
func _physics_process(delta):
	camera_follow()
	player_movement(delta)
	player_rotation()
	
	abilities()
	if (primary_attackrate.get_time_left() > 0):
		print(primary_attackrate.get_time_left())
	
func camera_follow():
	var player_pos = global_transform.origin
	rig.global_transform.origin = player_pos
	
func player_movement(delta):
	var input_vector = Vector3.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector3.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
	else:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
	
	return move_and_slide(velocity)

func player_rotation():
	var player_pos = global_transform.origin
	#var dropPlane  = Plane(Vector3(0, 1, 0), player_pos.y)
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_target = camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world().direct_space_state
	var intersection = space_state.intersect_ray(ray_origin, ray_target)
	
	if not intersection.empty():
		var pos = intersection.position
		var look = Vector3(pos.x, player_pos.y, pos.z)
		
		cursor.global_transform.origin = pos
		look_at(look, Vector3.UP)
	
func abilities():
	if Input.is_action_just_pressed("primary_ability") and primary_attackrate.get_time_left() == 0:
		primary_ability.disabled = false
		primary_attack.visible = true
		
		primary_attackrate.start()
		
	elif primary_attackrate.get_time_left() <= 0.35 or primary_attackrate.get_time_left() == 0:
		primary_ability.disabled = true
		primary_attack.visible = false
	
	if Input.is_action_pressed("secondary_ability") and secondary_attackrate.get_time_left() == 0:
		var new_projectile = Projectile.instance()
		new_projectile.global_transform = $Front.global_transform
		new_projectile.speed = 40
		var scene_root = get_tree().get_root().get_children()[0]
		scene_root.add_child(new_projectile)
		
		secondary_attackrate.start()
		
		#var mouse_pos = get_viewport().get_mouse_position()
		#var ray_origin = camera.project_ray_origin(mouse_pos)
		#var ray_target = camera.project_ray_normal(mouse_pos) * 1000

		#var space_state = get_world().direct_space_state
		#var intersection = space_state.intersect_ray(ray_origin, ray_target)


func _on_PrimaryHitbox_body_entered(body):
	print(body)

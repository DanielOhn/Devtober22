extends KinematicBody

var velocity = Vector3.ZERO
const speed = 15
const friction = 80

var health : int
var iframe : int

const primary_damage : int = 1

onready var rig : Position3D = $CameraRig
onready var camera : Camera = $CameraRig/Camera
onready var cursor : CSGMesh = $Cursor
onready var primary_ability : CollisionShape = $Front/PrimaryHitbox/CollisionShape

export var Projectile : PackedScene

onready var primary_attackrate : Timer = $PrimaryAttackrate
onready var secondary_attackrate : Timer = $SecondaryAttackrate

onready var animations : AnimationPlayer = $PlayerModel/Wizard/AnimationPlayer
onready var animTree : AnimationTree = $AnimationTree
onready var animState : AnimationNodeStateMachinePlayback = animTree.get("parameters/playback")

func _ready():
	rig.set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	primary_ability.disabled = true
	
func _physics_process(delta):
	camera_follow()
	player_movement(delta)
	player_rotation()
	abilities()
	
func camera_follow():
	var player_pos = global_transform.origin
	rig.global_transform.origin = player_pos
	
func player_movement(delta):
	var input_vector = Vector3.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.z = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if input_vector != Vector3.ZERO:
		animState.travel("Run")
		
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
	else:
		animState.travel("Idle")
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
	# Left Click Attack - Sword attack that hits in a small cone in front of player
	if Input.is_action_just_pressed("primary_ability") and primary_attackrate.get_time_left() == 0:
	
		# Starts timer
		animState.travel("Attack")
		primary_attackrate.start()


	# Right Click Attack - Shoots a ranged projectile to target location
	if Input.is_action_pressed("secondary_ability") and secondary_attackrate.get_time_left() == 0:
		animState.travel("Casting")
		secondary_attackrate.start()
	
func shoot():
	var new_projectile = Projectile.instance()
	new_projectile.global_transform = $Front.global_transform
	new_projectile.speed = 40
	
	var scene_root = get_tree().get_root().get_children()[0]
	scene_root.add_child(new_projectile)
	
func _on_PrimaryHitbox_body_entered(body):
	if primary_ability.disabled == false and body.is_in_group("Enemy"):
		print("HIT")
		body.hurt(primary_damage)

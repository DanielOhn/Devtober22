extends KinematicBody

var velocity = Vector3.ZERO
const speed = 15
const friction = 80

var health : int = 6
var score : int = 0

const primary_damage : int = 3
const primary_knockback : int = 40

onready var rig : Position3D = $CameraRig
onready var camera : Camera = $CameraRig/Camera
onready var cursor : CSGMesh = $Cursor
onready var primary_ability : CollisionShape = $Front/PrimaryHitbox/CollisionShape

export var Projectile : PackedScene

onready var primary_attackrate : Timer = $PrimaryAttackrate
onready var secondary_attackrate : Timer = $SecondaryAttackrate
onready var iframe : Timer = $IFrame

onready var animations : AnimationPlayer = $PlayerModel/Wizard/AnimationPlayer
onready var animTree : AnimationTree = $AnimationTree
onready var animState : AnimationNodeStateMachinePlayback = animTree.get("parameters/playback")

onready var hurt_anim : AnimationPlayer = $Hurt

onready var body : MeshInstance = $"PlayerModel/Wizard/control-rig/Skeleton2/Body"
onready var cloak : MeshInstance = $"PlayerModel/Wizard/control-rig/Skeleton2/BoneAttachment2/Cloak"
onready var hat : MeshInstance = $"PlayerModel/Wizard/control-rig/Skeleton2/BoneAttachment/Hat"

func _ready():
	rig.set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	primary_ability.disabled = true
	
func _physics_process(delta):
	if health > 0:
		camera_follow()
		player_movement(delta)
		player_rotation()
		abilities()

func flash():
	var body_material = body.get_surface_material(0)
	var cloak_material = cloak.get_surface_material(0)
	var hat_material = hat.get_surface_material(0)
	
	# White Color
	body_material.albedo_color = Color(1, 1, 1)
	body.set_surface_material(0, body_material)
	
	cloak_material.albedo_color = Color(1, 1, 1)
	cloak.set_surface_material(0, cloak_material)
	
	hat_material.albedo_color = Color(1, 1, 1)
	hat.set_surface_material(0, hat_material)

func returnColor():
	var body_material = body.get_surface_material(0)
	var cloak_material = cloak.get_surface_material(0)
	var hat_material = hat.get_surface_material(0)
	
	var blue = Color(0, 0, 1)
	var black = Color(0, 0, 0)
	
	body_material.albedo_color = black
	body.set_surface_material(0, body_material)
	
	cloak_material.albedo_color = blue
	cloak.set_surface_material(0, cloak_material)
	
	hat_material.albedo_color = blue
	hat.set_surface_material(0, hat_material)
	
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
	
	var scene_root = get_tree().get_root().get_children()[0]
	scene_root.add_child(new_projectile)

func hurt(damage):
	if iframe.is_stopped():
		health = health - damage
		iframe.start()
		hurt_anim.play("Hurt")
		
		if health <= 0:
			visible = false
	
func _on_PrimaryHitbox_body_entered(body):
	if primary_ability.disabled == false and body.is_in_group("Enemy"):
		body.hurt(primary_damage, primary_knockback)

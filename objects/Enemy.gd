extends KinematicBody

onready var player : KinematicBody =  $"../Player"
onready var nav : Navigation = $"../Navigation"

onready var collision : CollisionShape = $"Hurtbox/CollisionShape"
onready var hitbox : Area = $Hitbox

onready var animations : AnimationPlayer = $EnemyMesh/enemy3/AnimationPlayer
onready var animTree : AnimationTree = $AnimationTree
onready var animState : AnimationNodeStateMachinePlayback = animTree.get("parameters/playback")

var path : Array = []
var path_index = 0

var states : Array = ["Movement", "Attack", "Hurt"]
var state : String = states[0]

var speed = 10
var health = 5
var hitstun = 0
var wallstun = 0
var knockback = 0

func changeState(new_state):
	state = new_state

func _physics_process(delta):
	# Check State of Enemy
	if state == "Hurt":
		if wallstun > 0:
			hitstun = 0
			wallstun -= 1
		
		elif hitstun > 0:
			animState.travel("walk")
			var direction = path[path_index] - global_transform.origin
			var knockback : Vector3 = player.global_transform.origin - global_transform.origin
			hitstun -= 1
			
			direction.y = 0
			move_and_collide(-knockback.normalized() * 40 * delta)
		else:
			hitstun = 0
			changeState(states[0])

	if state == "Attack":
		animState.travel("attack")
	
	if state == "Movement":
		if path_index < path.size():
			var direction = path[path_index] - global_transform.origin
			var distance = global_transform.origin.distance_to(player.global_transform.origin)
			
			if distance < 1.5:
				state = states[1]
				
			else:
				if direction.length() < 1:
					path_index += 1
				else:
					var pos = player.global_transform.origin
					pos.y = 90
					
					look_at(pos, Vector3.UP)
					animState.travel("run")
					move_and_slide(direction.normalized() * speed, Vector3.UP)
			
func hurt(damage, knockback):
	# Apply damage to health
	# Check if enemy dies
	changeState(states[2])
	hitstun = 8
	health = health - damage
	
	if (health <= 0):
		# Play death animation then release
		# ADD DEATH ANIMATION
		player.score += 1
		queue_free()
		
func follow():
	path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
	path_index = 0

func _on_Timer_timeout():
	follow()

func _on_Hurtbox_body_entered(body):
	if (body.is_in_group("wall") and hitstun != 0):
		wallstun = hitstun + 20


func _on_Hitbox_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(2)

extends KinematicBody

onready var player : KinematicBody =  $"../Player"
onready var nav : Navigation = $"../Navigation"

onready var collision : CollisionShape = $"Hurtbox/CollisionShape"

var path : Array = []
var path_index = 0

var speed = 10
var health = 20
var hitstun = 0
var wallstun = 0
var knockback = 0

func _physics_process(delta):
	if path_index < path.size():
		
		
		if wallstun != 0:
			hitstun = 0
			wallstun -= 1
			# PLAY STUN ANIMATION
		else:
			var direction = path[path_index] - global_transform.origin
			if hitstun != 0:
				var knockback : Vector3 = player.global_transform.origin - global_transform.origin
				hitstun -= 1
				
				direction.y = 0
				move_and_collide(-knockback.normalized() * 40 * delta)
			
			else:
				knockback = 0
				if direction.length() < 1:
					path_index += 1
				else:
					var pos = player.global_transform.origin
					pos.y = 90
					
					look_at(pos, Vector3.UP)
					move_and_slide(direction.normalized() * speed, Vector3.UP)
				 

func hurt(damage, knockback):
	# Apply damage to health
	# Check if enemy dies
	knockback = knockback
	hitstun = 8
	health = health - damage
	if (health <= 0):
		# Play death animation then release
		# ADD DEATH ANIMATION
		queue_free()
	
	
	
func follow():
	path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
	path_index = 0

func _on_Timer_timeout():
	follow()

func _on_Hurtbox_body_entered(body):
	if (body.is_in_group("wall") and hitstun != 0):
		print("test")
		wallstun = hitstun + 20

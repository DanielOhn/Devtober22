extends Area

export var speed = 12

const knockback = 60
const damage = 5

const duration = 2
var timer = 0

func _physics_process(delta):
	var direction = global_transform.basis.z.normalized()
	global_translate(direction * speed * delta)
	
	timer += delta
	
	if timer > duration:
		queue_free()

func _on_Fireball_body_entered(body):
	print(body)
	if body.is_in_group("Enemy"):
		print("Fireball HIT!")
		body.hurt(damage, knockback)
		queue_free()
	elif body.is_in_group("wall"):
		queue_free()
		

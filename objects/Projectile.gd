extends Spatial

export var speed = 10

const duration = 2
var timer = 0

func _physics_process(delta):
	var direction = global_transform.basis.z.normalized()
	global_translate(direction * speed * delta)
	
	timer += delta
	
	if timer > duration:
		queue_free()

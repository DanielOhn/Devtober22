extends KinematicBody

onready var player : KinematicBody =  $"../Player"
onready var nav : Navigation = $"../Navigation"

var path : Array = []
var path_index = 0

var speed = 10

func _physics_process(delta):
	if path_index < path.size():
		var direction = path[path_index] - global_transform.origin
		if direction.length() < 1:
			path_index += 1
		else:
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func follow():
	path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
	path_index = 0

func _on_Timer_timeout():
	follow()

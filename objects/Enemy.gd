extends KinematicBody

onready var nav = $"../Navigation" as Navigation
onready var player = $"../Player" as KinematicBody

var path = []

func _ready():
	path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
	print(player.global_transform.origin)
	print(global_transform.origin)
	print(path)

func _physics_process(delta):
	pass

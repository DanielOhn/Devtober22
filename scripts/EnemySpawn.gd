extends StaticBody

onready var spawn : Area = $Spawn
onready var spawn_time : Timer = $SpawnTime

export var Enemy : PackedScene

func spawn_enemy():
	var new_enemy = Enemy.instance()
	new_enemy.global_transform = spawn.global_transform
	
	var scene_root = get_tree().get_root().get_children()[0]
	scene_root.add_child(new_enemy)
	
func _on_SpawnTime_timeout():
	spawn_enemy()

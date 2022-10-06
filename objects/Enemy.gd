extends KinematicBody

onready var player : KinematicBody =  $"../Player"

onready var navAgent : NavigationAgent = $NavigationAgent
var path = []

func _ready():
	navAgent.connect("velocity_computed", self, "_on_velocity_computed")
	

func _physics_process(delta):
	if navAgent.is_navigation_finished():
		return
	
	var target_position = navAgent.get_next_location()
	var direction  = global_transform.origin.direction_to(player.global_transform.origin)
	navAgent.set_velocity(navAgent.max_speed * direction)
	


func _on_velocity_computed(velocity):
	move_and_slide(velocity, Vector3.UP)

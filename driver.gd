extends Node

var player_node : Node2D
var slave_node : Node2D
var camera : Node2D
var travelling = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	var walk_dir = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), \
				Input.get_action_strength("down") - Input.get_action_strength("up")).normalized()
	
	var attack = Input.is_action_just_pressed("attack")
	
	if slave_node == null:
		return
	slave_node.recieve_input(walk_dir, attack)

func new_slave(target : Node2D):
	if slave_node == null:
		return
	slave_node.enslaved = false
	var travel_time = (slave_node.position - target.position).length() / 100
	slave_node = target
	travelling = true
	
	camera.splash(travel_time)
	yield(get_tree().create_timer(travel_time), "timeout")
	travelling = false
	slave_node.enslaved = true
	slave_node.awake = true
	slave_node.connect("health_changed", self, "on_health_changed")
	on_health_changed()

func on_health_changed():
	camera.update_health(slave_node.health)

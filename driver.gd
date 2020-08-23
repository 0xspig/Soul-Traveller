extends Node

var player_node : Node2D
var slave_node : Node2D
var camera : Node2D
var travelling = false

signal slave_changed()

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

onready var footsteps : AudioStreamPlayer = get_node("/root/Audio/Footsteps")

func _process(delta):

	if slave_node != null && slave_node.velocity.length() > 5 && !footsteps.playing:
		footsteps.play()
	elif slave_node != null && slave_node.velocity.length() > 5: 
		pass
	else:
		footsteps.stop()

	var walk_dir = Vector2(Input.get_action_strength("right") - Input.get_action_strength("left"), \
				Input.get_action_strength("down") - Input.get_action_strength("up")).normalized()
	
	var attack = Input.is_action_just_pressed("attack")
	
	var open = Input.is_action_just_pressed("open")
	
	if Input.is_action_just_pressed("return"):
		new_slave(player_node)
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("ui_cancel") && get_tree().get_root().get_node("Main_menu") == null:
		var menu : Node = camera.get_node("Control/Menu")
		if !menu.visible:
			menu.visible = true
			get_tree().paused = true
		else:
			menu.visible = false
			get_tree().paused = false
		if camera.get_node("Help_image").visible:
			camera.get_node("Help_image").visible = false
	if slave_node == null:
		return
	slave_node.recieve_input(walk_dir, attack, open)

func new_slave(target : Node2D):
	if slave_node == null:
		return
	if slave_node == target:
		return
	get_node("/root/Audio/Travel").play()
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
	emit_signal("slave_changed")
	on_health_changed()

func on_health_changed():
	camera.update_health(slave_node.health)

func change_scene(next_scene : String):
	get_tree().change_scene(next_scene)

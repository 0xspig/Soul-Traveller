extends KinematicBody2D

var health = 6

var splat = preload("res://Hit_splat.tscn")

signal health_changed()
var attackers : Array
var enslaved = true
const MOVE_SPEED = 60
var awake = true
# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/Driver".player_node = self
	$"/root/Driver".slave_node = self

var move_dir = Vector2(0, 0)
func recieve_input(movement : Vector2, attack : bool, open : bool):
	move_dir = movement

var time = 0
var velocity = Vector2(0,0)
var tween_cycle = false
func _physics_process(delta):
	time += delta
	if !enslaved:
		move_dir = Vector2(0,0)
	if velocity.length() < MOVE_SPEED:
		velocity += move_dir * 30
	velocity = move_and_slide(velocity)/1.2
	
	#movement wobble. this is probably the only good function in this entire game
	rotation = .1 * sin(time * 20) * int(velocity.length() > 20)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT && event.pressed:
		if $"/root/Driver".slave_node == self:
			return
		$"/root/Driver".new_slave(self)

func hit(source : Node, id, collision_point : Vector2):
	$Hit_sound.play()
	velocity = (position - collision_point).normalized() * 100
	health -= 1
	var new_splat = splat.instance() 
	get_parent().add_child(new_splat)
	new_splat.position = position + Vector2(0, 1)
	new_splat.splat(1)
	$Tween.interpolate_property($Sprite, "scale", Vector2(1.5, .5), Vector2(1, 1), .5,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	if health < 1:
		die()
	emit_signal("health_changed")

func die():
	get_parent().get_node("Camera").death()
	get_tree().paused = true

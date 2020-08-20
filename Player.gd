extends KinematicBody2D

var health = 6

signal health_changed()
var attackers : Array
var enslaved = true
const move_speed = 60
var awake = true
# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/Driver".player_node = self
	$"/root/Driver".slave_node = self

var move_dir = Vector2(0, 0)
func recieve_input(movement : Vector2, attack : bool):
	move_dir = movement

var velocity = Vector2(0,0)
func _physics_process(delta):
	if !enslaved:
		move_dir = Vector2(0,0)
	if velocity.length() < move_speed:
		velocity += move_dir * 30
	velocity = move_and_slide(velocity)/1.2

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT && event.pressed:
		if $"/root/Driver".slave_node == self:
			return
		$"/root/Driver".new_slave(self)

func hit(source : Node, id, collision_point : Vector2):
	velocity = (position - collision_point).normalized() * 100
	health -= 1
	$Tween.interpolate_property($Sprite, "scale", Vector2(1.5, .5), Vector2(1, 1), .5,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	emit_signal("health_changed")

extends KinematicBody2D

var splat = preload("res://Hit_splat.tscn")
var blood = preload("res://Blood.tscn")
onready var attack_target = $"/root/Driver".slave_node

enum {SLEEP, WALK, ATTACK, STUN, DEAD}

const MOVE_SPEED = 15
var class_id = 3
var state = SLEEP
var health = 50
var hit_count = 0
var velocity = Vector2(0, 0)
var move_dir = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/Driver".connect("slave_changed", self, "on_slave_changed")
	$Sword.caster = self

var time = 0
var walk_time = 0 
var attack_time = 0
var stun_time = 0
var attack_indicator = false
var swing_indicator = false
func _process(delta):
	if attack_target == null:
		on_slave_changed()
	time += delta
	if hit_count >= 3:
		hit_count = 0
		state = STUN
	if state == WALK:
		walk_time += delta
		print("Thmp")
		move_dir = (attack_target.position - position).normalized()
		$Position2D/Head.position = Vector2($Position2D.position.x + cos(time*5) * 3, $Position2D.position.x + sin(time*5) * 3)
		$Position2D/Head.scale = Vector2(1.68,1.68) + Vector2($Position2D/Head.position.y/20, $Position2D/Head.position.y/20)
		$Position2D/Head.rotation = 0
		$Torso.position.y = sin(time*2) * 2
		if walk_time > 2.5:
			walk_time = 0
			state = ATTACK
	if state == ATTACK:
		if !attack_indicator:
			attack_indicator = true
			$Attack.play()
		attack_time += delta
		print("Fee fi fo fum")
		move_dir = Vector2(0,0)
		$Position2D/Head.position = Vector2($Position2D.position.x + cos(time*100), 2)
		$Position2D/Head.scale = Vector2(1,1)
		$Position2D/Head.rotation = 0
		$Torso.position.y = sin(time*2) * 2
		if attack_time > .5:
			if !swing_indicator:
				$Swing.play()
				swing_indicator = true
			$Sword.position = Vector2(cos((attack_time -.5) *2.5) * 25, sin((attack_time -.5) *2.5) * 25)
			var angle = atan2($Sword.position.y , $Sword.position.x) + PI/2
			$Sword.rotation = angle
		if attack_time > 3:
			attack_time = 0
			state = WALK
			attack_indicator = false
			swing_indicator = false
	if state == STUN:
		stun_time += delta
		print("owie")
		move_dir = Vector2(0,0)
		$Position2D/Head.position = Vector2($Position2D.position.x + cos(time*5) * 3, $Position2D.position.x + sin(time*5) * 3)
		$Position2D/Head.scale = Vector2(1.68,1.68) + Vector2($Position2D/Head.position.y/20, $Position2D/Head.position.y/20)
		$Position2D/Head.rotation = sin(time) * TAU
		$Torso.position.y = sin(time*2) * 2
		if stun_time > 3:
			stun_time = 0
			state = WALK

func _physics_process(delta):
	if velocity.length() < MOVE_SPEED:
		velocity += move_dir * 2.5
	velocity = move_and_slide(velocity)/1.1

func hit(source : Node, id, collision_point : Vector2):
	if state == SLEEP:
		hit_count += 1
		health -= 5
		var new_splat = splat.instance()
		get_parent().add_child(new_splat)
		new_splat.position = position + Vector2(0, 10)
		new_splat.splat(5)
		state = WALK
	if state == WALK:
		hit_count += 1
		health -= 1
		var new_splat = splat.instance()
		get_parent().add_child(new_splat)
		new_splat.position = position + Vector2(0, 10)
		new_splat.splat(1)
	if state == STUN:
		health -= 5
		var new_splat = splat.instance()
		get_parent().add_child(new_splat)
		new_splat.position = position + Vector2(0, 10)
		new_splat.splat(5)
	$Hit.play()
	velocity = (position - collision_point).normalized() * 150
	$Tween.interpolate_property(self, "scale", Vector2(1.5, .5), Vector2(1, 1), .5,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()
	
	if health <= 0:
		die()
		

func die():
	print("boss dead")
	var level : TileMap = get_parent().get_node("TileMap")
	level.set_cellv(Vector2(-1, -20), level.tile_set.find_tile_by_name("magic_door_open"))
	var new_blood = blood.instance()
	get_parent().add_child(new_blood)
	new_blood.position = position
	new_blood.scale = Vector2(1.68, 1.68)
	state = DEAD
	rotation = PI/2

func on_slave_changed():
	attack_target = $"/root/Driver".slave_node

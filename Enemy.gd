extends KinematicBody2D

signal dead()
signal health_changed()

enum {WIZARD, KNIGHT, RANGER}

export var class_id = WIZARD 

var time = 0

var health = 6

var fireball = preload("res://Fireball.tscn")
var sword = preload("res://Sword.tscn")
var dagger = preload("res://Dagger.tscn")
var blood = preload("res://Blood.tscn")
var enslaved = false
var move_speed = 20
enum {SLEEP, WALK, ATTACK}
var state = SLEEP
var move_dir = Vector2(0,0)
var attack_target : Node2D
var awake = false
var attackers : Array

var attacking = false
# Called when the node enters the scene tree for the first time.
func _ready():
	match class_id:
		WIZARD:
			move_speed = 20
		RANGER:
			move_speed = 40
		KNIGHT:
			move_speed = 30

func _process(delta):
	if attack_target == null:
		attack_target = $"/root/Driver".slave_node
	time += delta
	if !enslaved && awake:
		ai(delta)

func ai(delta):
	match state:
		SLEEP:
			return
		WALK:
			walk_state(delta)
		ATTACK:
			attack_state()

var retreat = 0
func walk_state(delta):
	var target_position
	if attack_target != null:
		target_position = attack_target.position
	else:
		target_position = $"/root/Driver".player_node.position
	match class_id:
		WIZARD:
			move_dir = (target_position - position)
			if move_dir.length() <= 40:
				state = ATTACK
			move_dir = move_dir.normalized()
		RANGER:
			if retreat > 0:
				retreat -= delta
				move_dir = (position - target_position).rotated(.5 * sin(time*10))
			else:
				move_dir = (target_position - position).rotated(.5 * sin(time*10))
			if move_dir.length() <= 50 && move_dir.length() > 40 && retreat > 0:
				state = ATTACK
			elif move_dir.length() <= 40:
				retreat = .4
			move_dir = move_dir.normalized()
		KNIGHT:
			move_dir = (target_position - position)
			print(move_dir.length())
			if move_dir.length() <= 25:
				state = ATTACK
			move_dir = move_dir.normalized()

func attack_state():
	if attacking:
		return
	attacking = true
	var target_position
	if attack_target != null:
		target_position = attack_target.position
	else:
		target_position = $"/root/Driver".player_node.position
	match class_id:
		WIZARD:
			move_dir = Vector2(0, 0)
			attack(Vector2(target_position - position))
			yield(get_tree().create_timer(1), "timeout")
			if enslaved:
				attacking = false
				state = WALK
				return
			attacking = false
			state = WALK
		RANGER:
			move_dir = Vector2(0,0)
			velocity *= -.5
			attack(Vector2(target_position - position))
			state = WALK
			yield(get_tree().create_timer(.6), "timeout")
			attacking = false
		KNIGHT:
			move_dir = Vector2(0, 0)
			attack(Vector2(target_position - position))
			yield(get_tree().create_timer(1), "timeout")
			attacking = false
			state = WALK


const FIREBALL_SPEED = 40
const DAGGER_SPEED = 60
func attack(direction : Vector2):
	match class_id:
		WIZARD:
			var new_fireball = fireball.instance()
			new_fireball.caster = self
			get_parent().add_child(new_fireball)
			new_fireball.position = position + direction.normalized() * 7
			new_fireball.look_at(direction)
			new_fireball.linear_velocity = direction.normalized() * FIREBALL_SPEED
		RANGER:
			var new_dagger = dagger.instance()
			new_dagger.caster = self
			get_parent().add_child(new_dagger)
			new_dagger.position = position + direction.normalized() * 7
			new_dagger.look_at(direction)
			new_dagger.linear_velocity = direction.normalized() * DAGGER_SPEED
		KNIGHT:
			$Origin.rotation = atan2(direction.y, direction.x) + PI/2 - .5
			$Tween.interpolate_property($Origin, "rotation", 
					atan2(direction.y, direction.x) + PI/2 - .5, atan2(direction.y, direction.x) + PI/2 + .5, .1,
					Tween.TRANS_LINEAR)
			var new_sword = sword.instance()
			new_sword.caster = self
			get_node("Origin/Rotator").add_child(new_sword)
			new_sword.global_transform.origin = $Origin/Rotator.global_transform.origin + direction.normalized() * 5
			$Tween.start()
			yield($Tween, "tween_completed")
			new_sword.queue_free()
			

var velocity = Vector2(0,0)
func _physics_process(delta):
	if velocity.length() < move_speed:
		velocity += move_dir * 20
	velocity = move_and_slide(velocity) / 1.25

func recieve_input(movement, attack):
	move_dir = movement
	if attack:
		attack( get_global_mouse_position() - position)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT && event.pressed:
		if $"/root/Driver".slave_node == self:
			return
		new_attack_target()
		state = WALK
		$"/root/Driver".new_slave(self)

func hit(source : Node, id, collision_point : Vector2):
	match class_id:
		WIZARD:
			if id == KNIGHT:
				health -= 1
			elif id == RANGER:
				health -= 2
			emit_signal("health_changed")
		RANGER:
			if id == WIZARD:
				health -= 1
			if id == KNIGHT:
				health -= 2
			emit_signal("health_changed")
		KNIGHT:
			if id == RANGER:
				health -= 1
			if id == WIZARD:
				health -= 2
			emit_signal("health_changed")
	velocity = (position - collision_point).normalized() * 100
	if source != self && source != null:
		new_attack_target(source)
	if health <= 0:
		die()

	if awake == false:
		awake = true
		state = WALK
	$Tween.interpolate_property($Sprite, "scale", Vector2(1.5, .5), Vector2(1, 1), .5,
			Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$Tween.start()

func die():
	#do die animation
	var new_blood = blood.instance()
	get_parent().add_child(new_blood)
	new_blood.position = position
	new_blood.rotation = rand_range(0, TAU)
	if $"/root/Driver".slave_node == self:
		$"/root/Driver".new_slave($"/root/Driver".player_node)
	attack_target.attackers.erase(self)
	emit_signal("dead")
	queue_free()

func _on_target_killed():
	new_attack_target()

func check_target():
	if attack_target == null:
		new_attack_target()

func new_attack_target(new_target = $"/root/Driver".player_node):
	new_target.connect("dead", self, "_on_target_killed")
	attack_target = new_target
	emit_signal("target_changed")
	

func miss():
	pass











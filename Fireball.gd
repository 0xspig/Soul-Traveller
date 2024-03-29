extends RigidBody2D

const LIFETIME = 2
var bounces = 0
var time = 0

var caster : Node
var caster_id
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	time += delta
	var angle = atan2(linear_velocity.x, linear_velocity.y)
	$Particles2D.angle = rad2deg(angle)
	if time >= LIFETIME:
		queue_free()
		return


func _on_Fireball_body_entered(body : Node):
	if body.is_in_group("mgk_dmg"):
		print("burned ", str(body.name))
		#if player gets hit by fireball
		body.hit(caster, caster_id, position)
		queue_free()
		return
	if body.is_in_group("parry"):
		caster = body.caster
		set_collision_layer_bit(3, true)
		return
	if body.is_in_group("human"):
		#if player gets hit but is immune
		body.miss()
		queue_free()
		return
	if bounces >= 2:
		#make explosion particles
		queue_free()
		return
	bounces += 1

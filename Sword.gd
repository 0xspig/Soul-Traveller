extends RigidBody2D


var caster : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Sword_body_entered(body):
	if body.is_in_group("mle_dmg"):
		print("sliced ", str(body.name))
		#if player gets hit by fireball
		body.hit(caster, caster.class_id, position)
		return
	if body.is_in_group("human"):
		#if player gets hit but is immune
		body.miss()
		return

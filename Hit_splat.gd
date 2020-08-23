extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var played = false
func _process(delta):
	if !played:
		return
	if !$Particles2D.emitting:
		queue_free()

func splat(amount):
	$Particles2D.texture = load(str("number_", amount, ".png"))
	$Particles2D.emitting = true
	played = true

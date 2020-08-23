extends Area2D


export var next_scene : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_next_level_body_entered(body):
	if body.is_in_group("player"):
		get_parent().get_node("Camera").fade()
		get_tree().paused = true
		yield(get_parent().get_node("Camera").get_node("Tween"), "tween_completed")
		$"/root/Driver".change_scene(next_scene)

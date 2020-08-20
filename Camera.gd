extends Camera2D


const MOVE_SPEED = 100

var heart_full = preload("res://heart_full.png")
var heart_half = preload("res://heart_half.png")
var heart_empty = preload("res://heart_empty.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	$"/root/Driver".camera = self

func _process(delta):
	if $"/root/Driver".slave_node == null:
		return
	
	position.x = move_toward(global_transform.origin.x, $"/root/Driver".slave_node.global_transform.origin.x, delta * MOVE_SPEED)
	position.y = move_toward(global_transform.origin.y, $"/root/Driver".slave_node.global_transform.origin.y, delta * MOVE_SPEED)
	
func splash(time):
	$WarpFilter.material.set_shader_param("aberration_amount", 7.0)
	$WarpFilter.material.set_shader_param("move_aberration", true)
	$Tween.interpolate_property($WarpFilter.get_material(), "shader_param/intensity",
								0.0, 2.0, time/2, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	$Tween.interpolate_property($WarpFilter.get_material(), "shader_param/intensity",
								2.0, 0.0, time/2, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	$WarpFilter.material.set_shader_param("aberration_amount", .15)
	$WarpFilter.material.set_shader_param("move_aberration", false)

func update_health(health):
	$Tween.interpolate_property($Control/Hearts, "rect_position", 
						$Control/Hearts.rect_position - Vector2(3, 0), $Control/Hearts.rect_position,
						.4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	for i in $Control/Hearts.get_child_count():
		if health > i * 2 + 1:
			$Control/Hearts.get_child(i).texture = heart_full
		elif health > i * 2:
			$Control/Hearts.get_child(i).texture = heart_half
		else:
			$Control/Hearts.get_child(i).texture = heart_empty
	$Tween.start()
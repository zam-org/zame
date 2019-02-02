extends KinematicBody2D

var direction : = Vector2.LEFT
var speed : int = 100
# Called when the node enters the scene tree for the first time.
func _ready():
	modulate = Color(1,1,1,0)
	
func shoot():
	$Tween.interpolate_property(self, 'modulate', Color(1,1,1,0), Color(1,1,1,1), 2, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	rotation = direction.angle()
	$Timer.start()
	
func _physics_process(delta):
	var coll = move_and_collide(direction * delta * speed)
	if coll:
		#kill le player
		if coll.collider.name == "character":
			coll.collider.death()
			
		$CollisionShape2D.queue_free()
		$Line2D.visible = false
		$Particles.emitting = true
		yield(get_tree().create_timer(1), 'timeout')
		queue_free()
#	CURVED SHOTS		
#	direction = direction.rotated(0.1 * delta)
#	rotation = direction.angle()
	
func _on_Timer_timeout():
	$Tween.interpolate_property(self, 'modulate', Color(1,1,1,1), Color(1,1,1,0), 2, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0)
	$Tween.start()
	yield($Tween, 'tween_completed')
	queue_free()

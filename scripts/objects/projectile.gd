class_name Projectile extends AnimatableBody2D

@onready var queue_free_timer = $QueueFreeTimer
@onready var sprite_2d = $Sprite2D
@onready var collision_shape_2d = $WorldDetector/CollisionShape2D

@export var velocity:= Vector2(500, 0)
@export var physics_arrow_scene:PackedScene
var damage_mobs:bool
var deflected = false
var moving := true

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _physics_process(delta):
	if moving:
		position += velocity * delta
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true
	
func deflect(deflect_dir:Vector2):
	if not deflected:
		velocity = deflect_dir * velocity.length()
		deflected = true
		damage_mobs = true
		var arrow = physics_arrow_scene.instantiate() as PhysicsArrow
		get_parent().add_child(arrow)
		arrow.global_position = global_position
		arrow.sprite_2d.flip_h = !sprite_2d.flip_h	
		arrow.rotation = velocity.angle() + randf_range(-PI / 2, PI / 2)
		arrow.linear_velocity = Vector2(100, 0).rotated(arrow.rotation)
		queue_free()
	
func _on_queue_free_timer_timeout():
	queue_free()
	
func _on_world_detector_body_entered(body):
	moving = false
	set_deferred("process_mode", PROCESS_MODE_DISABLED)
	queue_free_timer.start()

func _on_mob_detector_body_entered(body):
	if damage_mobs:
		body.die()
		queue_free()

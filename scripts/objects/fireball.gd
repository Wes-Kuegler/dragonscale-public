class_name Fireball extends AnimatableBody2D


@export var velocity:= Vector2(120, 0)
var direction:Vector2

@onready var collision_shape_2d = $CollisionShape2D
@onready var collision_shape_2d_2 = $CollisionShape2D2
@onready var queue_free_timer = $QueueFreeTimer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var explosion_sound_player_2d = $ExplosionSoundPlayer2D

func _ready():
	set_direction()
	animated_sprite_2d.play("default")
	
func set_direction():
	animated_sprite_2d.rotation = direction.angle()
	velocity = Vector2(velocity.length(), 0).rotated(direction.angle())
	
func _physics_process(delta):
	position += velocity * delta
	
func deflect(deflect_dir:Vector2):
	collision_shape_2d.set_deferred("disabled", true)
	collision_shape_2d_2.set_deferred("disabled", true)
	await explode(deflect_dir.angle())
	queue_free()

func explode(explode_angle:float):
	animated_sprite_2d.rotation = PI / 2 #90 degrees, facing right
	animated_sprite_2d.rotate(explode_angle) #then rotate to face direction
	velocity = Vector2.ZERO
	collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.play("explosion")
	explosion_sound_player_2d.play()
	await animated_sprite_2d.animation_finished
	
func _on_world_detector_body_entered(body):
	var angle = body.position.angle_to(position)
	await explode(angle)
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free_timer.start()	 #must be off screen for timer length before being removed

func _on_visible_on_screen_notifier_2d_screen_entered():
	queue_free_timer.stop()
	
func _on_queue_free_timer_timeout():
	queue_free()

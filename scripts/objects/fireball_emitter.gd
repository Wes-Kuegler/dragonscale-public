class_name FireballEmitter extends Node2D

@export var fireball_scene:PackedScene
@export var shoot_direction:SHOOT_DIRECTION = SHOOT_DIRECTION.LEFT

enum SHOOT_DIRECTION
{
	LEFT,
	RIGHT	
}
@onready var fireball_sound_player = $FireballSoundPlayer
@onready var shoot_timer = $ShootTimer

@export var shooting:= false

func _ready():
	call_deferred("_on_shoot_timer_timeout")
	
func shoot():
	var fireball = fireball_scene.instantiate() as Fireball
	fireball.global_position = global_position
	fireball.direction = get_shoot_dir()
	get_parent().add_child(fireball)
#	fireball_sound_player.pitch_scale = randf_range(.9, 1)
	fireball_sound_player.play()
	
func get_shoot_dir() -> Vector2:
	match shoot_direction:
		SHOOT_DIRECTION.RIGHT:
			return Vector2(1, 0)
		SHOOT_DIRECTION.LEFT, _:
			return Vector2(-1, 0)
		
#	var delta_pos = Globals.player.position - position
#	if delta_pos.x < 0:
#		return Vector2(-1, 0)
#	else:
#		return Vector2(1, 0)

func _on_shoot_timer_timeout():
	if shooting:
		shoot()
		await get_tree().create_timer(.18).timeout
		shoot()
		await get_tree().create_timer(.18).timeout
		shoot()

func _on_player_detector_body_entered(body):
	shooting = true

func _on_player_detector_body_exited(body):
	shooting = false

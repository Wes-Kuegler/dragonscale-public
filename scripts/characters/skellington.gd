class_name Skellington extends CharacterBody2D

@export var shooting:bool
@export var projectile_scene:PackedScene
@export var mob_effect:MOB_EFFECT = MOB_EFFECT.SPEED

@onready var shoot_point = $ShootPoint as Node2D
@onready var shoot_point_starting_position:Vector2 = shoot_point.position
@onready var animation_tree = $AnimationTree
@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D
@onready var death_sound_player_2d = $DeathSoundPlayer2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_dir = -1
enum MOB_EFFECT {
	SPEED,
	BOUNCE
}

func _ready():
	animation_tree.active = true
	
func _physics_process(delta):
	set_facing_dir()
	if not is_on_floor():
		velocity.y = gravity 
		move_and_slide()

func shoot(direction:int):
	var projectile = projectile_scene.instantiate() as Projectile
	var shoot_angle
	if direction == 1:
		shoot_angle = 0
	elif direction == -1:
		shoot_angle = PI
	shoot_point.position = shoot_point_starting_position.rotated(shoot_angle)
	projectile.velocity = projectile.velocity.rotated(shoot_angle)
	projectile.global_position = shoot_point.global_position
	get_parent().add_child(projectile)

func set_facing_dir():
	var delta_pos = Globals.player.position - position
	if delta_pos.x < 0:
		facing_dir = -1
	else:
		facing_dir = 1 
	
func die():
	death_sound_player_2d.pitch_scale = randf_range(1, 1.25)
	death_sound_player_2d.play()
	collision_shape_2d.set_deferred("disabled", true)
	animation_tree.active = false
	animation_player.play("die")
	await animation_player.animation_finished
	queue_free()
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	shooting = false

func _on_visible_on_screen_notifier_2d_screen_entered():
	shooting = true

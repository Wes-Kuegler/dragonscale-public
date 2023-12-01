extends Node2D

@onready var player_sprite_animation_player = $PlayerSpriteAnimationPlayer
@onready var movement_animation_player = $MovementAnimationPlayer
@onready var scale_animation_player = $ScaleAnimationPlayer
@onready var scale_position_animation_player = $ScalePositionAnimationPlayer
@onready var parallax_background = $ParallaxBackground
@onready var wing_beat_player_2d = $WingBeatPlayer2D
@onready var wing_beats_timer = $WingBeatsTimer
@onready var scale_falling_sound_player_2d = $ScaleSprite2D/ScaleFallingSoundPlayer2D
@onready var scale_impact_sound_player_2d = $ScaleSprite2D/ScaleImpactSoundPlayer2D
@onready var scale_pickup_sound_player = $ScalePickupSoundPlayer
@onready var walk_sound_player = $WalkSoundPlayer
@onready var color_rect = $ColorRect
@onready var button_animation_player = $ButtonAnimationPlayer

var walking = false
var fade_time = 1

func _ready():
	call_deferred("start_animation")
	
func _process(delta):
	parallax_background.scroll_offset += Vector2(delta * 10, 0)
	
func start_animation():
	button_animation_player.play("fade_in")
	color_rect.hide()
	Fade.fade_in(fade_time, Color.BLACK, "Diamond")
	await get_tree().create_timer(fade_time).timeout
	play_animation()
	
func play_animation():
	wing_beat_player_2d.play()
	await wing_beats_timer.timeout
	animate_scale()
	
func animate_player():
	player_sprite_animation_player.play("Empty Walk")
	movement_animation_player.play("walk_across")
	walk_sound_player.play()
	walking = true
	await movement_animation_player.animation_finished
	player_sprite_animation_player.play("Look up")
	walking = false
	await player_sprite_animation_player.animation_finished
	player_sprite_animation_player.play("Stand Empty")
	await player_sprite_animation_player.animation_finished
	player_sprite_animation_player.play("Grab")
	scale_pickup_sound_player.play()
	scale_animation_player.play("Crater")
	await player_sprite_animation_player.animation_finished
	player_sprite_animation_player.play("Equiped")	
	await player_sprite_animation_player.animation_finished
	end_animation()

func animate_scale():
	scale_falling_sound_player_2d.play()
	await get_tree().create_timer(.5).timeout
	scale_animation_player.play("Falling Scale")
	scale_position_animation_player.play("falling")
	await scale_position_animation_player.animation_finished
	call_deferred("animate_player")
	scale_animation_player.play("Landed Scale")
	scale_impact_sound_player_2d.play()

func end_animation():
	Fade.fade_out(fade_time, Color.BLACK, "Diamond") 
	await get_tree().create_timer(fade_time).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	Fade.fade_in(fade_time, Color.BLACK, "Diamond")


func _on_wing_beat_player_2d_finished():
	if !wing_beats_timer.is_stopped():
		wing_beat_player_2d.play()

func _on_skip_button_pressed():
	end_animation()

func _on_walk_sound_player_finished():
	if walking:
		#add a time delay between footsteps because he's walking slower than in game
		await get_tree().create_timer(.1).timeout
		walk_sound_player.play()

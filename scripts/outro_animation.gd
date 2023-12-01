extends Node2D

@onready var dragon_crying_sound_player_2d = $DragonCryingSoundPlayer2D
@onready var dragon_animation_player = $DragonAnimationPlayer
@onready var walk_sound_player = $WalkSoundPlayer
@onready var player_sprite_animation_player = $PlayerSpriteAnimationPlayer
@onready var movement_animation_player = $MovementAnimationPlayer
@onready var scale_animation_player = $ScaleAnimationPlayer
@onready var victory_sound_player = $VictorySoundPlayer
@onready var outro_song_player = $OutroSongPlayer
@onready var parallax_background = $ParallaxBackground
@onready var tilemap_animation_player = $TilemapAnimationPlayer
@onready var scale_sprite_2d = $TileMap/ScaleSprite2D

var walking = false
var dragon_crying = true

func _ready():
	call_deferred("start_animation")

func start_animation(): 
	SaveManager.save_data.outro_played = true
	SaveManager.save_player_data()
	var fade_time = 1
	Fade.fade_in(fade_time, Color.BLACK, "Diamond")
	await get_tree().create_timer(fade_time).timeout
	get_tree().paused = false
	dragon_crying_sound_player_2d.play()
	dragon_animation_player.play("Crying")
	animate_player()
	outro_song_player.play()
	
func _process(delta):
	parallax_background.scroll_offset += Vector2(delta * 10, 0)
	
func animate_player():
	player_sprite_animation_player.play("walk_right")
	movement_animation_player.play("walk_across")
	walk_sound_player.play()
	walking = true
	await movement_animation_player.animation_finished
	walking = false
	player_sprite_animation_player.play("Grab")
	await player_sprite_animation_player.animation_finished
	scale_sprite_2d.show()
	player_sprite_animation_player.play("Stand Empty")
	await player_sprite_animation_player.animation_finished
	player_sprite_animation_player.play("Look up")
	dragon_animation_player.play("Stop Crying")
	dragon_crying = false
	await dragon_animation_player.animation_finished
	dragon_animation_player.play("Idle no cry")
#	victory_sound_player.play()
	await player_sprite_animation_player.animation_finished
	await get_tree().create_timer(1.5).timeout
	pan_up()
	
func pan_up():
	tilemap_animation_player.play("pan_up")
	outro_song_player.stream.loop = false
	await outro_song_player.finished
	end_animation()
	
func end_animation():
	#do some sort of fade to black here
	var fade_time = 1
	Fade.fade_out(fade_time, Color.BLACK, "Diamond") 
	await get_tree().create_timer(fade_time).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")
	Fade.fade_in(fade_time, Color.BLACK, "Diamond")

func _on_dragon_crying_sound_player_2d_finished():
	if dragon_crying:
		dragon_crying_sound_player_2d.pitch_scale = randf_range(.5, .7)
		dragon_crying_sound_player_2d.volume_db = randi_range(-12, -9)
		dragon_crying_sound_player_2d.play()

func _on_walk_sound_player_finished():
	if walking:
		#add a time delay between footsteps because he's walking slower than in game
		await get_tree().create_timer(.1).timeout
		walk_sound_player.play()

func _on_stage_select_button_pressed():
	end_animation()

extends Node

var current_stage:Node2D
var current_stage_scene:PackedScene

@onready var music_player = $MusicPlayer as AudioStreamPlayer

func _ready():
	EventBus.reset_stage.connect(reload_stage)
	EventBus.load_stage.connect(load_stage)
	EventBus.play_song.connect(play_song)
	EventBus.unload_stage.connect(clear_stage)
		
func load_stage(stage_data:StageData):
	clear_stage()
	current_stage_scene = load(stage_data.scene_path)
	StageManager.current_stage = stage_data
	instantiate_stage()
	play_song(stage_data.stage_track)
	EventBus.stage_loaded.emit()
	
func instantiate_stage():
	current_stage = current_stage_scene.instantiate()
	add_child(current_stage)

func reload_stage():
	clear_stage()
	instantiate_stage()

func clear_stage():
	if current_stage:
		remove_child(current_stage)
		current_stage.queue_free()
		current_stage = null

func play_song(stream:AudioStream):
	music_player.stream = stream
	music_player.play()

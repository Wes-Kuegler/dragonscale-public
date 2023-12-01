class_name StageSelect extends Control

@export var menu_theme:AudioStream
@onready var grid_container = %GridContainer as GridContainer
@onready var stage_buttons:Dictionary = {} # Key is button, value is stage data

@onready var sample_button = %SampleButton as Button
@onready var sample_label = %SampleLabel as Label

@export var post_game_bonus_stage:StageData
func _ready():
#	EventBus.player_data_ready.connect(get_stages)
	call_deferred("play_menu_music")
	await get_tree().create_timer(.2).timeout
	get_stages()
	
func clear_entries():
	for child in grid_container.get_children():
		if (child as Control).visible:
			grid_container.remove_child(child)
			
func play_menu_music():
	EventBus.play_song.emit(menu_theme)

func get_stages():
	clear_entries()
	var keys = StageManager.stages.keys()
	keys.sort()
	var prior_stage_id:float
	for stage_id in keys:
		var stage_data = StageManager.stages[stage_id]
		var button:Button = sample_button.duplicate()
		button.visible = true
		stage_buttons[button] = stage_data
		button.text = stage_data.name
		button.pressed.connect(_on_button_pressed.bind(button))
		if prior_stage_id: #if there is a preceding stage
			#disable if the preceding stage was not completed
			var prior_stage_completion := SaveManager.get_stage_completion(prior_stage_id)
			button.disabled = !prior_stage_completion
			if stage_id == post_game_bonus_stage.id and !prior_stage_completion:
				button.visible = false
				break
		grid_container.add_child(button)
		var label = sample_label.duplicate() as Label
		label.visible = true
		var stage_time = SaveManager.get_stage_time(stage_data.id)
		var time_string = Globals.format_stage_time(stage_time) if stage_time > 0 else "   "
		label.text = "Best Time: " + time_string
		grid_container.add_child(label)
		prior_stage_id = stage_id

func _on_button_pressed(button:Button):
	var data:StageData = stage_buttons[button]
	EventBus.load_stage.emit(data)
	hide()

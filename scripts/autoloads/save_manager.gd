extends Node

const SAVE_DATA_PATH = "user://save_data.tres"
var save_data:SaveData 

func _ready():
	EventBus.stage_complete.connect(_on_stage_complete)
	load_player_data()
#	#stinky time delay to ensure stage select populates correctly
#	await get_tree().create_timer(.1).timeout
#	EventBus.player_data_ready.emit()
	
func load_player_data():
	if !FileAccess.file_exists(SAVE_DATA_PATH):
		save_data = SaveData.new()
	else:
		var data = ResourceLoader.load(SAVE_DATA_PATH)
		if data:
			save_data = data
		else:
			save_data = SaveData.new()
		
func save_player_data():
	if save_data:
		ResourceSaver.save(save_data, SAVE_DATA_PATH)

func get_stage_time(stage_id:float) -> float:
	if save_data and save_data.stage_times:
			if save_data.stage_times.has(stage_id):
				return save_data.stage_times[stage_id]
	return 0
	
func get_stage_completion(stage_id:float) -> bool:
	if save_data.stage_completion.has(stage_id):
		return save_data.stage_completion[stage_id]
	return false
	
func _on_stage_complete():
	var id = StageManager.current_stage.id
	save_data.stage_completion[id] = true
	if !save_data.stage_times.has(id) or Globals.stage_time < save_data.stage_times[id]:
		save_data.stage_times[id] = Globals.stage_time
	save_player_data()

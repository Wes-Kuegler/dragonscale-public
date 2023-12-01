extends MarginContainer

@onready var time_label = $MarginContainer/VBoxContainer/HBoxContainer/TimeLabel
@onready var best_time_label = $MarginContainer/VBoxContainer/HBoxContainer2/BestTimeLabel
@onready var end_button = $MarginContainer/VBoxContainer/EndButton
@onready var stage_select_button = $MarginContainer/VBoxContainer/StageSelectButton
@onready var victory_label = $MarginContainer/VBoxContainer/VictoryLabel
@onready var restart_button = $MarginContainer/VBoxContainer/RestartButton

@export var final_stage:StageData
func _on_button_pressed():
	EventBus.reset_stage.emit()
	get_tree().paused = false

func _on_visibility_changed():
	if visible:
		victory_label.text = StageManager.current_stage.name + " - Complete!"
		time_label.text = Globals.format_stage_time(Globals.stage_time)
		best_time_label.text = Globals.format_stage_time(\
			SaveManager.get_stage_time(StageManager.current_stage.id))
			
		#if we just finished the last stage 
		if StageManager.current_stage.id == final_stage.id:
			if !SaveManager.save_data.outro_played: #force watch first time
				restart_button.hide()
				stage_select_button.hide()
			end_button.show()
		else:
			restart_button.show()
			stage_select_button.show()

func _on_stage_select_button_pressed():
	get_tree().paused = false
	EventBus.unload_stage.emit()
	hide()

func _on_end_button_pressed():
	end_button.hide()
	var fade_time = 1
	Fade.fade_out(fade_time, Color.BLACK, "Diamond") 
	await get_tree().create_timer(fade_time).timeout
	get_tree().change_scene_to_file("res://scenes/outro_animation.tscn")

extends Control

@onready var ui:UI = get_parent()
@onready var sound_menu = $SoundMenu

func _input(event):
	if event.is_action_pressed("pause") and StageManager.current_stage and !ui.victory_screen.visible:
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			show()
		else:
			hide()
			sound_menu.hide()
			
func _on_stage_select_button_pressed():
	get_tree().paused = false
	EventBus.unload_stage.emit()
	hide()


func _on_restart_button_pressed():
	hide()
	EventBus.reset_stage.emit()
	get_tree().paused = false


func _on_sound_menu_button_pressed():
	sound_menu.show()

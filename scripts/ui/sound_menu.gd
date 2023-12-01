extends PanelContainer

@onready var MASTER_BUS_ID = AudioServer.get_bus_index("Master")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var pause_menu = get_parent()

@onready var master_volume_h_slider = %MasterVolumeHSlider
@onready var music_volume_h_slider = %MusicVolumeHSlider

func _on_master_volume_h_slider_drag_ended(value_changed):
	if value_changed:
		AudioServer.set_bus_volume_db(MASTER_BUS_ID, master_volume_h_slider.value)

func _on_music_volume_h_slider_drag_ended(value_changed):
	if value_changed:
		AudioServer.set_bus_volume_db(MUSIC_BUS_ID, music_volume_h_slider.value)

func _on_back_button_pressed():
	hide()

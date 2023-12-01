extends Node

const STAGE_DIR := "res://scenes/stages/"
const STAGE_DATA_DIR := "res://resources/stage_data/"

var current_stage:StageData
var stages:Dictionary = {} #Key is stage ID, value is stage data
			
func _ready():
	load_stage_data()
	EventBus.unload_stage.connect(clear_current_stage)
	
func load_stage_data():
	var dir := DirAccess.open(STAGE_DATA_DIR)
	for file in dir.get_files():
		var splitname := file.split(".") # rememer
		if splitname[1] == "tres": #resource files
			file = file.rstrip(".remap")
			var stage_data:StageData = ResourceLoader.load(STAGE_DATA_DIR + file)
			stages[stage_data.id] = stage_data

func clear_current_stage():
	current_stage = null

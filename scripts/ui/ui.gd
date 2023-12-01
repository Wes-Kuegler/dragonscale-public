class_name UI extends CanvasLayer

@onready var victory_screen = $VictoryScreen
@onready var stage_time_label = $ClockMarginContainer/StageTimeLabel as Label
@onready var clock_margin_container = $ClockMarginContainer
@onready var parallax_background = $ParallaxBackground
@onready var stage_select = $StageSelectContainer/StageSelect as StageSelect 

var stage_time:float = 0:
	set(value):
		stage_time = value
		Globals.stage_time = value
		stage_time_label.text = Globals.format_stage_time(value)
		
var clock_stopped = true

func _ready():
	EventBus.reset_stage.connect(hide_victory_screen)
	EventBus.reset_stage.connect(start_clock)
	EventBus.stage_loaded.connect(start_clock)
	EventBus.unload_stage.connect(show_stage_select)
	EventBus.player_died.connect(stop_clock)
	EventBus.stage_complete.connect(_on_stage_complete)
	Globals.ui = self
	
func _process(delta):
	if !clock_stopped and !get_tree().paused:
		stage_time += delta
	if stage_select.visible:
		parallax_background.scroll_offset += Vector2(delta * 10, 0)
	
func show_victory_screen():
	victory_screen.show()	
	
func hide_victory_screen():
	victory_screen.hide()
	
func stop_clock():
	clock_stopped = true
	
func start_clock():
	show_clock()
	clock_stopped = false
	stage_time = 0

func show_clock():
	clock_margin_container.show()

func show_stage_select():
	clock_margin_container.hide()
	stage_select.show()
	stage_select.get_stages()
	stage_select.play_menu_music()
	
func _on_stage_complete():
	stop_clock()
	show_victory_screen()
	

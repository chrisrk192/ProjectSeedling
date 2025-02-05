extends Sprite2D

signal boundry_updated(new_size: Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

var text_bubble
func showText(timeline_string) -> void:
	#Dialogig Test
	# check if a dialog is already running
	if Dialogic.current_timeline != null:
		return
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var layout = Dialogic.Styles.load_style("text_bubble_style")
	layout.register_character(load("res://dialog/ai.dch"), $".")
	text_bubble = Dialogic.start(timeline_string)
	add_child(text_bubble)
	
func showCustomText(text: String) -> void:
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	var layout = Dialogic.Styles.load_style("text_bubble_style")
	layout.register_character(load("res://dialog/ai.dch"), $".")
	
	
	
	var events: Array = []
	# Create a TextEvent
	var text_event = DialogicTextEvent.new()
	text_event.text = text
	text_event.character = load("res://dialog/ai.dch")
	events.append(text_event)

	# Assign events to the timeline
	var timeline: DialogicTimeline = DialogicTimeline.new()
	timeline.events = events
	timeline.events_processed = true  # Necessary if events are already resources
	text_bubble = Dialogic.start(timeline)
	add_child(text_bubble)
	
func _on_timeline_ended() -> void:
	print("_on_timeline_ended")
	text_bubble = null
	var new_size = Vector2(0, 0)
	emit_signal("boundry_updated", new_size)
	
func _on_animation_textbox_new_text() -> void:
	print("new text")
	#var timer:SceneTreeTimer = get_tree().create_timer(1.0)  
	#timer.timeout.connect(_resize_for_text) 
	#_resize_for_text()

var last_winSize: Vector2
func _resize_for_text() -> void:
	text_bubble.get_child(2).get_child(1).get_child(0).get_child(0).position = Vector2(64,10)
	var dialog_box_rect = text_bubble.get_child(2).get_child(1).bubble_rect
	var winSize = dialog_box_rect.size
	if(last_winSize != winSize):
		print(winSize)
		last_winSize = winSize
		emit_signal("boundry_updated", winSize)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if text_bubble != null:
		_resize_for_text()

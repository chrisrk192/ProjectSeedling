extends Node2D

@export var ai_window: PackedScene
@export var chat_interface: Chat 
#@onready var _MainCamera: Camera2D = get_node(main_camera)
@onready var _MainWindow: Window = get_window()
@onready var _MainScreen: int = _MainWindow.current_screen
@onready var _MainScreenRect: Rect2i = DisplayServer.screen_get_usable_rect(_MainScreen)

var world_offset: = Vector2i.ZERO

var ai_window_instance: PlayerWindow
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	# display->window->transparent has to be set to true in the project setting, in IDE´s Menu "Project->Project Settings...",
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)
	_MainWindow.gui_embed_subwindows = false # Make subwindows actual system windows <- VERY IMPORTANT
	
	# Set the window settings - most of them can be set in the project settings
	#_MainWindow.borderless = true		# Hide the edges of the window
	# Otherwise _MainWindow.transparent doesn't affect the player´s sprite (tested in Godot 4.2.2)
	_MainWindow.transparent = false		# Allow the window to be transparent
	# Settings that cannot be set in project settings
	_MainWindow.transparent_bg = false	# Make the window's background transparent

	
	ai_window_instance = create_ai_window()
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func create_ai_window() -> PlayerWindow:
	var new_window: PlayerWindow = ai_window.instantiate()
	# Pass the main window's world to the new window
	# This is what makes it possible to show the same world in multiple windows
	#new_window.world_2d = _MainWindow.world_2d
	#new_window.world_3d = _MainWindow.world_3d
	
	# Set the window settings - most of them can be set in the project settings
	new_window.borderless = true		# Hide the edges of the window
	new_window.unresizable = true		# Prevent resizing the window
	new_window.always_on_top = true	# Force the window always be on top of the screen
	new_window.gui_embed_subwindows = false # Make subwindows actual system windows <- VERY IMPORTANT
	# display->window->transparent has to be set to true in the project setting, in IDE´s Menu "Project->Project Settings...",
	# Otherwise _MainWindow.transparent doesn't affect the player´s sprite (tested in Godot 4.2.2)
	new_window.transparent = true		# Allow the window to be transparent
	# Settings that cannot be set in project settings
	new_window.transparent_bg = true	# Make the window's background transparent
	
	add_child(new_window)
	return new_window

var buffer: String = ""
var in_action: bool = false  # Track whether we're inside an action (*...*)

func parse_token(token: String):
	for char in token:
		if char == "*":
			if in_action:
				# Exiting action mode
				buffer += "*"
				dispatch_message(buffer)
				buffer = ""
				in_action = false
			else:
				# Entering action mode
				if buffer.strip_edges():  # Dispatch normal text before starting an action
					dispatch_message(buffer)
					buffer = ""
				buffer += "*"
				in_action = true
			continue
		
		buffer += char
	
	# Dispatch a normal sentence if it ends with a period and we're not in an action
	if not in_action and (buffer.ends_with(".") or buffer.ends_with("?")):
		dispatch_message(buffer)
		buffer = ""
		
func dispatch_message(buffer):
	ai_window_instance.say(buffer)
	
func _on_panel_container_token_recieved(token: String) -> void:
	parse_token(token)
	

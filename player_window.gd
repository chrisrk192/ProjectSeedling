extends Window

@onready var player_sprite: Sprite2D = $Player_Sprite
@onready var _MainWindow: Window = get_window()
var _window_id
#@onready var char_sprite: AnimatedSprite2D = $Character/AnimatedSprite2D
#@onready var emitter: CPUParticles2D = $Character/CPUParticles2D

var player_size: Vector2i = Vector2i(128,128)
#The offset between the mouse and the character
var mouse_offset: Vector2 = Vector2.ZERO
var selected: bool = false
#This will be the position of the pet above the taskbar
var taskbar_pos: int = (DisplayServer.screen_get_usable_rect().size.y - player_size.y)
var screen_width: int = DisplayServer.screen_get_usable_rect().size.x



var is_falling: bool = false
var on_ground: bool = true
var is_walking: bool = true
var walk_direction: int = 1
#Character walk speed
const WALK_SPEED = 150
# Gravity acceleration in pixels per second squared
var gravity = 1000.0
# Initial vertical velocity
var velocity = Vector2.ZERO
# Previous mouse position to calculate delta
var prev_mouse_pos = Vector2.ZERO

func _ready():
	#Change the size of the window
	_MainWindow.min_size = player_size
	_MainWindow.size = _MainWindow.min_size
	_window_id = _MainWindow.get_window_id()
	#Places the character in the middle of the screen and on top of the taskbar
	_MainWindow.position = Vector2i(DisplayServer.screen_get_size().x/2 - (player_size.x/2), taskbar_pos)
	player_sprite.showText('test_timeline')
	#player_sprite.showCustomText("魔法陣")

func _process(delta):
	check_for_selection() #checks for selection
	
	if selected:
		follow_mouse(delta)
	if(_MainWindow.position.y + _modulatedY <= taskbar_pos - 1):
		on_ground = false
	else:
		on_ground = true
		#velocity = 0
		
	if not on_ground and not selected:
		is_falling = true
	else:
		is_falling = false
		
	if is_falling:
		fall(delta)

	#if is_walking:
		#walk(delta)
		

	if not selected:
		var floorY = (taskbar_pos) - _modulatedY
		var rightWall = screen_width - _modulatedX
		_MainWindow.position = Vector2i(
			clampi(_MainWindow.position.x + (velocity.x * delta), -_modulatedX/2, rightWall), 
			clampi((_MainWindow.position.y + (velocity.y * delta)), 0, floorY)
		) 
		#Bounce off the walls
		if(_MainWindow.position.x - 1 < 1 - _modulatedX/2):
			#print("bump left ", velocity.x)
			velocity.x = -velocity.x * .5
		if(_MainWindow.position.y - 1 < 1):
			#print("bump top")
			velocity.y = -velocity.y * .5
		if(_MainWindow.position.x + 1 >= rightWall):
			#print("bump right")
			velocity.x = -velocity.x * .5
		if(_MainWindow.position.y + 1 >= floorY):
			#print("bump bottom")
			if(velocity.length_squared() > gravity * gravity):
				velocity.y = -velocity.y * .5
			else:
				velocity.y = 0
		#friction
		if on_ground:
			velocity.x = velocity.x / 1.25
		else:
			velocity.x = velocity.x / 1.0025
	#emit heart particles when petted
	#if Input.is_action_just_pressed("pet"):
		#emitter.emitting = true

func follow_mouse(delta):
	var mouse_pos = DisplayServer.mouse_get_position()
	# Offset if you want the window to follow with some gap
	var offset = Vector2i(-_MainWindow.size.x / 2, -_MainWindow.size.y / 2)

	# Smooth position update to avoid flickering
	var current_pos = Vector2(DisplayServer.window_get_position(_window_id))
	var target_pos = mouse_pos + offset
	var new_pos = current_pos.lerp(target_pos, 0.1)  # Smooth movement
	# Set position of the specific window
	DisplayServer.window_set_position(new_pos,_window_id)
	
	## Move the window with the mouse
	var mouse_delta = new_pos - current_pos
	## Track the delta to set velocity when released
	velocity = mouse_delta / delta

func check_for_selection():
	#On right click and hold it will follow the pet and when released
	#it will stop following
	if Input.is_action_pressed("move"):
		selected = true
		is_walking = false
	if Input.is_action_just_released("move"):
		selected = false
		is_walking = true

func fall(delta):
	# Update velocity based on gravity
	velocity.y += gravity * delta

func clamp_on_screen_width(pos, player_width):
	return clampi(pos, 0, screen_width - player_width)
	
func clamp_on_screen_height(pos, player_height):
	return clampi(pos, 0, taskbar_pos - player_height)

func walk(delta):
	return
	#Moves the pet
	_MainWindow.position.x = _MainWindow.position.x + WALK_SPEED * delta * walk_direction
	#Clamps the pet position on the width of screen
	_MainWindow.position.x = clampi(_MainWindow.position.x, 0
			,clamp_on_screen_width(_MainWindow.position.x, player_size.x))
	#Changes direction if it hits the sides of the screen
	if ((_MainWindow.position.x == (screen_width - player_size.x)) or (_MainWindow.position.x == 0)):
		walk_direction = walk_direction * -1
		#char_sprite.flip_h = !char_sprite.flip_h

func choose_direction():
	if (randi_range(1,2) == 1):
		walk_direction = 1
		#char_sprite.flip_h = false
	else:
		walk_direction = -1
		#char_sprite.flip_h = true

func _on_character_walking():
	is_walking = true
	choose_direction()

func _on_character_finished_walking():
	is_walking = false
	
func _modulate_window_size(deltaX, deltaY):
	_MainWindow.size.x += deltaX
	_MainWindow.size.y += deltaY
	_MainWindow.position.y -= deltaY
	_MainWindow.position.x -= deltaX/2
	player_sprite.position.y += deltaY
	player_sprite.position.x += deltaX/2
	

var _modulatedX = 0
var _modulatedY = 0
func _on_player_sprite_boundry_updated(new_size: Vector2) -> void:
	print(new_size)
	_modulate_window_size(-_modulatedX, -_modulatedY)
	_modulate_window_size(new_size.x, new_size.y)
	_modulatedX = new_size.x
	_modulatedY = new_size.y
	

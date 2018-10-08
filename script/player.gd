extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 250 # pixels/sec
const JUMP_SPEED = 480
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2
const LERP_SPEED = .1

var linear_vel = Vector2()
var scale_transform = Vector2()
var onair_time = 0 #
var on_floor = false
var shoot_time=99999 #time since last shot
var jumping = false
var hp = 23
var power = 0

var anim=""

#cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $sprite
onready var hp_bar = $ui.find_node("hp")
onready var power_bar = $ui.find_node("power")

func _physics_process(delta):
	#increment counters

	onair_time += delta
	shoot_time += delta

	### MOVEMENT ###

	# Apply Gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and Slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect Floor
	if is_on_floor():
		onair_time = 0
		jumping = false

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###

	# Horizontal Movement
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed += -1
	if Input.is_action_pressed("move_right"):
		target_speed +=  1

	target_speed *= WALK_SPEED
	#linear_vel.x = lerp(linear_vel.x, target_speed, LERP_SPEED)
	linear_vel.x = target_speed


	# Jumping
	if on_floor and Input.is_action_just_pressed("jump"):
		linear_vel.y = -JUMP_SPEED
		jumping = true
	
	if jumping and !Input.is_action_pressed("jump") and linear_vel.y < 0:
		linear_vel.y = 0
		jumping = false

	
	### POWER ###

	if power > 0:
		power -= (delta * 15)
	else:
		power = 0
	
	if Input.is_action_just_pressed("pump"):
		power += 5

	### ANIMATION ###

	# scale_transform.y = lerp(scale_transform.y, (abs(linear_vel.y) * 0.0005), LERP_SPEED)
	# #scale_transform.x = lerp(scale_transform.x, (abs(linear_vel.x) * 0.0005), LERP_SPEED)

	# sprite.scale.y = 1 + scale_transform.y - scale_transform.x
	# sprite.scale.x = 1 - scale_transform.y + scale_transform.x

	var new_hp = 23

	if new_hp != hp:
		hp = new_hp
		hp_bar.frame = new_hp
	
	power_bar.frame = power
		
	
	# var new_anim = "idle"
	# if on_floor:
	# 	if linear_vel.x < -SIDING_CHANGE_SPEED:
	# 		sprite.scale.x = -1
	# 		new_anim = "run"

	# 	if linear_vel.x > SIDING_CHANGE_SPEED:
	# 		sprite.scale.x = 1
	# 		new_anim = "run"
	# else:
	# 	# We want the character to immediately change facing side when the player
	# 	# tries to change direction, during air control.
	# 	# This allows for example the player to shoot quickly left then right.
	# 	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
	# 		sprite.scale.x = -1
	# 	if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
	# 		sprite.scale.x = 1

	# 	if linear_vel.y < 0:
	# 		new_anim = "jumping"
	# 	else:
	# 		new_anim = "falling"

	# if shoot_time < SHOOT_TIME_SHOW_WEAPON:
	# 	new_anim += "_weapon"

	# if new_anim != anim:
	# 	anim = new_anim
	# 	$anim.play(anim)

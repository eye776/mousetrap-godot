#The MIT License (MIT) 
#Copyright (c) 2016

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is furnished
#to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
#DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
#ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
#OR OTHER DEALINGS IN THE SOFTWARE.

extends Node2D

onready var vp = get_viewport_rect()

onready var cat = get_node("cat")
onready var mouse = get_node("mouse")
onready var food = get_node("food")
onready var hpbar = get_node("hpbar")
onready var sfx = get_node("sfx")

const MouseAiState_Evading = 0
const MouseAiState_Wander = 1

const MaxCatSpeed = 7.5
const MaxMouseSpeed = 8.5
const MouseTurnSpeed = 0.2
const MouseEvadeDistance = 200.0
const MouseHysteresis = 60.0

const TwoPi = 6.28319

var catPosition = Vector2()
var catOrientation = 0.0

var mousePosition = Vector2()
var mouseState = MouseAiState_Wander
export var mouseHP = 100
var mouseOrientation = 0.0
var mouseWanderDirection = Vector2()

export var wanderTime = 3
var getFood = false

export var gameOver = false
export var gameWon = false

func _ready():
	#mouseHP = 100
	set_process(true)
	set_fixed_process(true)
	set_process_input(true)
	randomize()
	catPosition = Vector2(vp.size.width / 2, vp.size.height / 2)
	mousePosition = Vector2(3 * vp.size.width / 4, vp.size.height / 2)
	cat.set_pos(catPosition)
	mouse.set_pos(mousePosition)
	hpbar.set_value(mouseHP)

func clamp_to_viewport(vector):
	vector.x = clamp(vector.x, vp.pos.x, vp.pos.x + vp.size.width)
	vector.y = clamp(vector.y, vp.pos.y, vp.pos.y + vp.size.height)
	return vector

const DEADZONE = 0.2

func handle_input():
	if(Input.is_action_pressed("ui_cancel")):
		Fader.fade_to_scene("res://menu.scn")
	var catMovement = Vector2(0, 0)
	catMovement.x = Input.get_joy_axis(0, JOY_AXIS_0)
	catMovement.y = Input.get_joy_axis(0, JOY_AXIS_1)
	if(abs(catMovement.x) < DEADZONE):
		catMovement.x = 0
	if(abs(catMovement.y) < DEADZONE):
		catMovement.y = 0
	if(Input.is_action_pressed("ui_left")):
		catMovement.x -= 1.0
	if(Input.is_action_pressed("ui_right")):
		catMovement.x += 1.0
	if(Input.is_action_pressed("ui_up")):
		catMovement.y -= 1.0
	if(Input.is_action_pressed("ui_down")):
		catMovement.y += 1.0
	if (catMovement == Vector2(0, 0) && pressed):
		catMovement = delta
	if (catMovement != Vector2(0, 0)):
		catMovement = catMovement.normalized()
	var oldPosition = catPosition
	catPosition += catMovement * MaxCatSpeed
	if (catMovement != Vector2(0, 0)):
		catOrientation = turn_to_face(oldPosition, catPosition, catOrientation, MouseTurnSpeed)

func wander(position, turnSpeed):
	mouseWanderDirection.x += lerp(-0.25, 0.25, randf())
	mouseWanderDirection.y += lerp(-0.25, 0.25, randf())
	if (mouseWanderDirection != Vector2()):
		mouseWanderDirection = mouseWanderDirection.normalized()
	var targetPosition = Vector2()
	if(getFood == true):
		targetPosition = food.get_pos()
		mouseOrientation = turn_to_face(position, targetPosition, mouseOrientation, 0.15 * turnSpeed)
	else:
		targetPosition = position + mouseWanderDirection
		mouseOrientation = turn_to_face(position, targetPosition, mouseOrientation, 0.15 * turnSpeed)
		var screenCenter = Vector2(vp.size.width / 2, vp.size.height / 2)
		var distanceFromScreenCenter = screenCenter.distance_to(position)
		var maxDistanceFromScreenCenter = min(screenCenter.y, screenCenter.x)
		var normalizedDistance = distanceFromScreenCenter / maxDistanceFromScreenCenter
		var turnToCenterSpeed = 0.3 * normalizedDistance * normalizedDistance * turnSpeed
		mouseOrientation = turn_to_face(position, screenCenter, mouseOrientation, turnToCenterSpeed)

func update_mouse():
	var distanceFromCat = mousePosition.distance_to(catPosition)
	if (distanceFromCat > MouseEvadeDistance + MouseHysteresis):
		mouseState = MouseAiState_Wander
		mouse.set_modulate(Color("ffffff"))
	elif (distanceFromCat < MouseEvadeDistance - MouseHysteresis):
		mouseState = MouseAiState_Evading
		mouse.set_modulate(Color("f16e6e"))
	var currentMouseSpeed
	if (mouseState == MouseAiState_Evading):
		var seekPosition = 2 * mousePosition - catPosition
		if(seekPosition.x < vp.pos.x || seekPosition.x > vp.pos.x + vp.size.width ||\
			seekPosition.y < vp.pos.y || seekPosition.y > vp.pos.y + vp.size.height):
			seekPosition.x = vp.pos.x + vp.size.width / 2
			seekPosition.y = vp.pos.y + vp.size.height / 2
		mouseOrientation = turn_to_face(mousePosition, seekPosition, mouseOrientation, MouseTurnSpeed)
		currentMouseSpeed = MaxMouseSpeed
	else:
		wander(mousePosition, MouseTurnSpeed)
		currentMouseSpeed = 0.25 * MaxMouseSpeed
	var heading = Vector2(cos(mouseOrientation), sin(mouseOrientation));
	mousePosition += heading * currentMouseSpeed

func wrap_angle(radians):
	while (radians < -PI):
		radians += TwoPi
	while (radians > PI):
		radians -= TwoPi
	return radians

func turn_to_face(position, faceThis, currentAngle, turnSpeed):
	var x = faceThis.x - position.x
	var y = faceThis.y - position.y
	var desiredAngle = atan2(y, x)
	var difference = wrap_angle(desiredAngle - currentAngle)
	difference = clamp(difference, -turnSpeed, turnSpeed)
	return wrap_angle(currentAngle + difference)

func end_game(over, won):
	gameOver = over
	gameWon = won
	if(gameWon):
		get_node("win").show()
		get_node("retry").show()
		get_node("menu").show()
	if(gameOver):
		get_node("lose").show()
		get_node("retry").show()
		get_node("menu").show()

func _process(delta):
	if(gameWon || gameOver):
		return
	if(wanderTime >= 0):
		wanderTime -= delta
	else:
		getFood = !getFood
		wanderTime = 3
	#print(str("wanderTime ", wanderTime, " getFood ", getFood))
	handle_input()
	update_mouse()
	catPosition = clamp_to_viewport(catPosition)
	mousePosition = clamp_to_viewport(mousePosition)
	cat.set_rot(-catOrientation)
	cat.set_pos(catPosition)
	mouse.set_rot(-mouseOrientation)
	mouse.set_pos(mousePosition)

var dt = 0
var dispHP = 100
var squeak = 0
var meow = 0

func squeak():
	if(gameWon || gameOver):
		return
	if(sfx.is_voice_active(squeak) == false):
		squeak = sfx.play("squeak")
		sfx.set_volume(squeak, 0.3)

func meow():
	if(gameWon || gameOver):
		return
	if(sfx.is_voice_active(meow) == false):
		meow = sfx.play("meow")
		sfx.set_volume(meow, 0.2)

func _fixed_process(delta):
	if(cat.get_pos().distance_squared_to(mouse.get_pos()) <= 5625):
		mouseHP -= 20 * delta
		meow()
		if(mouseHP <= 0):
			end_game(false, true)
	if(dispHP > mouseHP):
		dt += delta / 3
		if(dt >= 1):
			dt = 0
		dispHP = lerp(dispHP, mouseHP, dt)
	hpbar.set_value(dispHP)

var pressed = false
var last_position = Vector2()
var delta = Vector2()

func _input(event):
	if(event.type == InputEvent.MOUSE_BUTTON):
		pressed = event.is_pressed()
		if pressed:
			last_position = event.pos
	elif(event.type == InputEvent.MOUSE_MOTION && pressed):
		var ndelta = event.pos - last_position
		delta.x = clamp(ndelta.x, -1, 1)
		delta.y = clamp(ndelta.y, -1, 1)
		last_position = event.pos

func _on_menu_pressed():
	Fader.fade_to_scene("res://menu.scn")

func _on_retry_pressed():
	Fader.fade_to_scene("res://game.scn")

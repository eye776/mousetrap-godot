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

onready var screen_size = OS.get_screen_size(0)
onready var window_size = OS.get_window_size()

func _ready():
	OS.set_window_position(screen_size / 2 - window_size / 2)
	get_node("AnimationPlayer").play("drop")

func _on_QuitGame_pressed():
	self.get_tree().quit()

func _on_Credits_pressed():
	get_node("NewGame").hide()
	get_node("Credits").hide()
	get_node("QuitGame").hide()
	get_node("ScrollContainer").show()
	get_node("Button").show()

func _on_Button_pressed():
	get_node("NewGame").show()
	get_node("Credits").show()
	get_node("QuitGame").show()
	get_node("ScrollContainer").hide()
	get_node("Button").hide()

func _on_NewGame_pressed():
	Fader.fade_to_scene("res://game.scn")

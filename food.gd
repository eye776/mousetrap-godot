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

extends Sprite

onready var mouse = get_parent().get_node("mouse")
onready var foodText = get_parent().get_node("foodText")
onready var sfx = get_parent().get_node("sfx")

var food = 6

func _ready():
	set_process(true)
	randomize()
	rand_food()

func rand_food():
	var bounds = self.get_region_rect().size
	var x = floor(rand_range(0.0, 0.8) * 10) * 128 + 64 + bounds.width / 2
	var y = floor(rand_range(0.0, 0.6) * 10) * 128 + 64 + bounds.height / 2
	self.set_pos(Vector2(x, y))
	self.set_frame(food - 1)

var eating = 0

func _process(delta):
	#print(str(get_parent().mouseState))
	if(self.get_pos().distance_squared_to(mouse.get_pos()) <= 4225 && get_parent().mouseState == 1):
		food -= 1
		if(food <= 0):
			food = 0
			get_parent().end_game(true, false)
		else:
			if(sfx.is_voice_active(eating) == false):
				eating = sfx.play("eating")
				sfx.set_volume(eating, 0.3)
			rand_food()
		foodText.set_text(str("FOOD: ", food))
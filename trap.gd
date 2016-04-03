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

const tileSize = 128
const halfTileSize = 64

onready var mouse = get_parent().get_node("mouse")
onready var scoreText = get_parent().get_node("scoreText")

var score = 0

func rand_rangei(lo, hi):
	return rand_range(lo/10.0, hi/10.0) * 10

func _ready():
	set_process(true)
	randomize()
	rand_trap()

func rand_trap():
	var bounds = self.get_region_rect().size
	var x = floor(rand_rangei(0, 8)) * tileSize + halfTileSize + bounds.width / 2
	var y = floor(rand_rangei(0, 6)) * tileSize + halfTileSize + bounds.height / 2
	self.set_pos(Vector2(x, y))

func _process(delta):
	if(self.get_pos().distance_squared_to(mouse.get_pos()) <= 5625):
		get_parent().mouseHP -= 10
		get_parent().squeak()
		if(get_parent().mouseHP <= 0):
			get_parent().end_game(false, true)
		else:
			rand_trap()
			score += 1
			scoreText.set_text(str("SCORE: ", score))
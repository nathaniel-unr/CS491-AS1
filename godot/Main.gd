# Name: Nathaniel Daniel
# Email: nathanieldaniel@nevada.unr.edu

extends Control

const tile_script = preload("res://Tile.gd")
const font_data = preload("res://Roboto-Regular.ttf")

var lookup_map = null

const MAX_DIFFICULTY: int = 1000 # 20
const MIN_DIFFICULTY: int = 1

var tiles: Array = []
var difficulty: int = MIN_DIFFICULTY

var win_layer: CanvasLayer = null
var difficulty_label: Label = null

func _ready():
	randomize()
	
	var file = File.new()
	file.open("res://generated.json", File.READ)
	lookup_map = parse_json(file.get_as_text())
	
	for i in range(16):
		var c = ColorRect.new()
		c.set_script(tile_script)
		c.update_id(i)
		c.update_position(i)
		tiles.append(c)
		self.add_child(c)
	win_layer = get_node("WinLayer")
	difficulty_label = get_node("UI/DifficultyLabel")
	update_difficulty(MIN_DIFFICULTY)
	
	while is_win():
		reset_board()
		make_n_random_moves(difficulty)
		win_layer.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func up():
	# All but first row
	for i in range(4, 16):
		var i_alt = i - 4
		if tiles[i_alt].is_empty():
			swap_tiles(i, i_alt)
			return true
	return false
		
func right():
	for i in range(16):
		if (i == 3) || (i == 7) || (i == 11) || (i == 15):
			continue
		
		var i_alt = i + 1
		if tiles[i_alt].is_empty():
			swap_tiles(i, i_alt)
			return true
	return false
		
func down():
	# All but last row
	for i in range(16 - 4):
		var i_alt = i + 4
		if tiles[i_alt].is_empty():
			swap_tiles(i, i_alt)
			return true
	return false
			
func left():
	for i in range(16):
		if i % 4 == 0:
			continue
		
		var i_alt = i - 1
		if tiles[i_alt].is_empty():
			swap_tiles(i, i_alt)
			return true
	return false
			
func swap_tiles(i, i_alt):
	var tile = tiles[i]
	var tile_alt = tiles[i_alt]
		
	tiles[i] = tile_alt
	tiles[i_alt] = tile
			
	tile.update_position(i_alt)
	tile_alt.update_position(i)
	
func is_win():
	for i in range(16):
		var tile = tiles[i]
		
		if tile.id != i:
			return false
	return true
	
func make_n_random_moves(n):
	for _i in range(n):
		var moved = false
		while not moved:
			var choice = randi() % 4
			match choice:
				0:
					moved = up()
				1: 
					moved = down()
				2: 
					moved = left()
				3: 
					moved = right()

func compareTiles(tile1, tile2):
	return tile1.id < tile2.id 
	
func reset_board():
	tiles.sort_custom(self, "compareTiles")
	for tile in tiles:
		tile.update_position(tile.id)

func update_difficulty(new):
	difficulty = int(clamp(new, MIN_DIFFICULTY, MAX_DIFFICULTY))
	difficulty_label.text = 'Difficulty: ' + String(difficulty) 
	
func ai_move():
	var key = ''
	for i in range(16):
		var tile = tiles[i]
		key += String(tile.id)
		if i != 15:
			key += ','
	var value = lookup_map.get(key)
	if value != null:
		value = value.split(',')
		for i in range(16):
			tiles[i].update_id(int(value[i]))

func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if is_win():
				update_difficulty(difficulty + 1)
				
				while is_win():
					reset_board()
					make_n_random_moves(difficulty)
					win_layer.visible = false
			else:
				match event.scancode:
					KEY_UP, KEY_W:
						up()
					KEY_RIGHT, KEY_D:
						right()
					KEY_DOWN, KEY_S:
						down()
					KEY_LEFT, KEY_A:
						left()
					KEY_R:
						update_difficulty(difficulty - 1)
						reset_board()
						while is_win():
							make_n_random_moves(difficulty)
							win_layer.visible = false
					KEY_H:
						ai_move()
						
				var is_win = is_win()
				win_layer.visible = is_win

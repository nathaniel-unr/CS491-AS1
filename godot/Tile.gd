# Name: Nathaniel Daniel
# Email: nathanieldaniel@nevada.unr.edu

extends Node

const font_data = preload("res://Roboto-Regular.ttf")

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var id = -1

var dynamic_font = null
var label: Label = Label.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var r = ReferenceRect.new()
	r.border_color = Color(0, 0, 0)
	r.editor_only = false
	r.anchor_right = 1
	r.anchor_bottom = 1
	r.border_width = 4
	
	r.margin_bottom = 2
	r.margin_top = 2
	r.margin_left = 2
	r.margin_right = 2
	
	dynamic_font = DynamicFont.new()
	dynamic_font.font_data = font_data
	dynamic_font.size = 120
	
	label.name = "Label"
	label.text = String(id + 1)
	label.add_font_override("font", dynamic_font)
	label.add_color_override("font_color", Color(0, 0, 0, 1))
	label.align = Label.ALIGN_CENTER
	label.valign = Label.ALIGN_CENTER
	label.anchor_right = 1
	label.anchor_bottom = 1
	
	self.add_child(label)
	self.add_child(r)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func is_empty():
	return id == 15

func update_position(index):
	var row = index % 4
	var col = int(index / 4.0)
	
	self.anchor_left = (1.0 / 4.0) * float(row)
	self.anchor_top = (1.0 / 4.0) * float(col)
	self.anchor_right = (1.0 / 4.0) * float(row + 1)
	self.anchor_bottom = (1.0 / 4.0) * float(col + 1)
	
func update_id(new_id):
	self.name = 'Tile' + String(new_id + 1)
	self.id = new_id
	self.label.text = String(new_id + 1)
	
	var default_row = new_id % 4
	var default_col = int(new_id / 4.0)
	
	if self.is_empty():
		self.color = Color(0, 0, 0, 1)
	elif (default_row % 2 == 0) == (default_col % 2 == 0):
		self.color = Color(1, 0, 0, 1)
	else:
		self.color = Color(1, 1, 1, 1)

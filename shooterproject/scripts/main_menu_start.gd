extends Control


func _ready():
	var button = Button.new()
	button.text = "New game"
	button.pressed.connect(self._button_pressed)
	add_child(button)

func _button_pressed():
	get_tree().root.add_child(preload("res://scenes/map.tscn").instantiate())

extends CanvasLayer

@onready var restart_button = $Control/Button

func _ready():
	restart_button.pressed.connect(_on_restart_pressed)
	visible = false  # Скрываем экран победы изначально

func show_victory():
	visible = true  # Показываем экран победы
	get_tree().paused = true  # Останавливаем игру

func _on_restart_pressed():
	get_tree().paused = false  # Убираем паузу
	get_tree().reload_current_scene()  # Перезапускаем уровень

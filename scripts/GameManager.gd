extends Node

var total_enemies: int = 0
var defeated_enemies: int = 0

@onready var victory_screen = $CharacterBody2D/VictoryScreen  # Убедись, что у тебя есть экран победы

func _ready():
	victory_screen.visible = false  # Скрываем экран победы в начале

func register_enemy():
	total_enemies += 1

func enemy_defeated():
	defeated_enemies += 1
	if defeated_enemies >= total_enemies:
		show_victory_screen()

func show_victory_screen():
	victory_screen.visible = true
	get_tree().paused = true  # Останавливаем игру

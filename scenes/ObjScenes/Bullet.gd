extends Node2D  # Убедитесь, что это Area2D

signal hit

@export var speed: float = 5000  # Скорость пули
@onready var audio_player = $AudioStreamPlayer # Ссылка на AudioStreamPlayer

func shoot():
	audio_player.play()  # Проигрываем звук стрельбы
	set_process(true)  # Включаем процесс для обновления позиции пули

func _process(delta):
	position += Vector2.RIGHT.rotated(rotation) * speed * delta  # Двигаем пулю
	

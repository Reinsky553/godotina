extends Area2D

@export var heal_amount: int = 50  # Количество восстанавливаемого здоровья

@onready var pickup_sound = $PickupSound
@onready var sprite = $Sprite2D  # Спрайт аптечки
@onready var collision = $CollisionShape2D  # Коллизия аптечки

func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):  # Проверяем, что игрок взял аптечку
		body.heal(heal_amount)  # Восстанавливаем здоровье игроку
		
		# Отключаем аптечку визуально, чтобы не мешалась
		sprite.visible = false
		collision.set_deferred("disabled", true)

		# Проигрываем звук и ждем его завершения
		if pickup_sound:
			pickup_sound.play()
			await pickup_sound.finished  # Ждем, пока звук закончится

		queue_free()  # Удаляем аптечку из сцены

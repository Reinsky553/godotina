extends Node2D  

signal hit  

@export var speed: float = 5000  # Скорость пули
@export var damage: int = 10  # Урон от пули
var shooter: Node2D = null  # Кто выпустил пулю

func shoot():
	set_process(true)  # Включаем процесс для обновления позиции пули

func _process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	var motion = direction * speed * delta

	# Проверяем столкновение
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, position + motion)
	var result = space_state.intersect_ray(query)

	if result:
		var hit_object = result.collider
		queue_free()
		if hit_object.has_method("take_damage"):  # Проверяем, есть ли метод take_damage
			if shooter.is_in_group("enemy") and hit_object.is_in_group("player"):
				hit_object.take_damage(damage)  # Наносим урон игроку
			elif shooter.is_in_group("player") and hit_object.is_in_group("enemy"):
				hit_object.take_damage(damage)  # Наносим урон врагу
	else:
		position += motion

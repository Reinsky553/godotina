extends CharacterBody2D

@export var speed: float = 100  # Скорость врага
@export var max_hp: int = 50  # Максимальное здоровье врага
@export var reload_time: float = 2.0  # Время перезарядки

var hp: int  # Текущее здоровье врага
var target: Node2D  # Цель (игрок)
var is_dead: bool = false  # Флаг смерти врага

@onready var detection_zone = $DetectionZone  # Зона обнаружения игрока
@onready var weapon = $M4  # Оружие врага (нода с скриптом enemy_weapon.gd)
@onready var death_animation = $AnimationPlayer  # Анимация смерти
@onready var game_manager = get_tree().get_first_node_in_group("game_manager")  # Менеджер игры

func _ready():
	hp = max_hp  # Устанавливаем начальное здоровье

	if game_manager:
		game_manager.register_enemy()  # Регистрируем врага в менеджере игры

	# Подключаем сигналы зоны обнаружения
	detection_zone.body_entered.connect(_on_body_entered)
	detection_zone.body_exited.connect(_on_body_exited)

func _process(delta):
	if target and not is_dead:
		# Двигаемся к цели (игроку)
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

# Обработка входа игрока в зону обнаружения
func _on_body_entered(body):
	if body.is_in_group("player"):
		target = body  # Устанавливаем цель
		weapon.set_target(target)  # Передаем цель в оружие
		print("Цель установлена: ", target.name)  # Отладочное сообщение

# Обработка выхода игрока из зоны обнаружения
func _on_body_exited(body):
	if body == target:
		target = null  # Сбрасываем цель
		weapon.set_target(null)  # Сбрасываем цель в оружии
		velocity = Vector2.ZERO  # Останавливаем движение
		print("Цель сброшена")  # Отладочное сообщение

# Метод для получения урона
func take_damage(amount: int):
	if is_dead:
		return  # Если враг уже мертв, ничего не делаем

	hp -= amount  # Уменьшаем здоровье
	print("Враг получил урон: ", amount)  # Отладочное сообщение

	if hp <= 0:
		die()  # Если здоровье <= 0, вызываем метод die()

# Метод для смерти врага
func die():
	if is_dead:
		return  # Если враг уже мертв, ничего не делаем

	is_dead = true  # Устанавливаем флаг смерти
	weapon.set_target(null)  # Останавливаем стрельбу
	velocity = Vector2.ZERO  # Останавливаем движение

	if death_animation:
		death_animation.play("death")  # Проигрываем анимацию смерти
		await death_animation.animation_finished  # Ждем завершения анимации

	if game_manager:
		game_manager.enemy_defeated()  # Уведомляем менеджер игры о смерти врага

	queue_free()  # Удаляем врага из сценыas

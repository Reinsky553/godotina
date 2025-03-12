extends CharacterBody2D

@export var max_hp: int = 100  # Максимальное здоровье игрока
var hp: int  # Текущее здоровье игрока

signal hit  # Сигнал, который можно использовать для оповещения о получении урона

@export var speed: int = 200  # Скорость движения игрока
var screen_size: Vector2  # Размер экрана
var target_velocity = Vector2.ZERO  # Вектор движения игрока
var is_game_ended: bool = false  # Флаг окончания игры

@onready var WalkSound = $AudioStreamPlayer2D  # Звук ходьбы
@onready var health_bar = $CanvasLayer/HealthBar  # UI-элемент для отображения здоровья
@onready var damage_overlay = $CanvasLayer/DamageOverlay  # Эффект повреждения
@onready var hit_sound = $DamageSound  # Звук получения урона
@onready var game_over_screen = $CanvasLayer/GameOverScreen  # Экран "Game Over"
@onready var restart_button = $CanvasLayer/GameOverScreen/Button  # Кнопка перезапуска

func _ready():
	screen_size = get_viewport_rect().size  # Получаем размер экрана
	hp = max_hp  # Устанавливаем начальное здоровье
	update_health_ui()  # Обновляем UI здоровья
	damage_overlay.modulate.a = 0  # Скрываем эффект повреждения

	# Подключаем кнопку перезапуска
	restart_button.pressed.connect(_on_button_pressed)

func _physics_process(_delta):
	target_velocity = Vector2.ZERO  # Сбрасываем вектор движения

	# Обработка ввода для движения
	if Input.is_action_pressed("move_right"):
		target_velocity.x += 1
	if Input.is_action_pressed("move_left"):
		target_velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		target_velocity.y += 1
	if Input.is_action_pressed("move_up"):
		target_velocity.y -= 1

	if !is_game_ended:
		if target_velocity.length() > 0:
			target_velocity = target_velocity.normalized() * speed  # Нормализуем вектор и умножаем на скорость
			$AnimatedSprite2D.play()  # Запускаем анимацию ходьбы
			if !WalkSound.playing:
				WalkSound.play()  # Воспроизводим звук ходьбы
		elif WalkSound.playing:
			WalkSound.stop()  # Останавливаем звук ходьбы
		else:
			$AnimatedSprite2D.stop()  # Останавливаем анимацию

	velocity = target_velocity
	move_and_slide()  # Двигаем игрока

	# Обновляем анимацию в зависимости от направления движения
	if !is_game_ended:
		if velocity.x > 0:
			$AnimatedSprite2D.animation = "right"
		elif velocity.x < 0:
			$AnimatedSprite2D.animation = "left"
		elif velocity.y < 0:
			$AnimatedSprite2D.animation = "up"
		elif velocity.y > 0:
			$AnimatedSprite2D.animation = "down"

# Метод для получения урона
func take_damage(amount: int):
	print("Игрок получил урон: ", amount)  # Отладочное сообщение
	hp -= amount  # Уменьшаем здоровье
	update_health_ui()  # Обновляем UI здоровья

	if hp <= 0:
		die()  # Если здоровье <= 0, вызываем метод die()

	if hit_sound:
		hit_sound.play()  # Воспроизводим звук получения урона

	if damage_overlay:
		damage_overlay.modulate.a = 0.5  # Показываем эффект повреждения
		var tween = get_tree().create_tween()
		tween.tween_property(damage_overlay, "modulate:a", 0, 0.5)  # Плавно скрываем эффект

# Обновление UI здоровья
func update_health_ui():
	if health_bar:
		health_bar.value = hp  # Обновляем значение ProgressBar

# Метод для смерти игрока
func die():
	print("Игрок умер")  # Отладочное сообщение
	game_over_screen.visible = true  # Показываем экран "Game Over"
	get_tree().paused = true  # Останавливаем игру

# Метод для начала игры (например, при респавне)
func start(pos):
	position = pos  # Устанавливаем позицию игрока
	show()  # Показываем игрока
	$CollisionShape2D.disabled = false  # Включаем коллайдер

# Обработка нажатия кнопки перезапуска
func _on_button_pressed():
	get_tree().paused = false  # Убираем паузу
	get_tree().reload_current_scene()  # Перезапускаем уровень

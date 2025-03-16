extends Node2D

@export var bullet_scene: PackedScene  # Префаб пули (должен быть назначен в редакторе)
@export var fire_rate: float = 0.5  # Интервал между выстрелами
@export var max_ammo: int = 10  # Максимальный боезапас
@export var reload_time: float = 2.0  # Время перезарядки

var ammo: int
var reloading: bool = false
var target: Node2D = null  # Цель (игрок)

@onready var fire_point = $Mka/Muzzle  # Точка появления пули (Marker2D)
@onready var fire_timer = $FireTimer  # Таймер для задержки между выстрелами
@onready var fire_sound = $AudioStreamPlayer2  # Звук выстрела
@onready var reload_sound = $AudioStreamPlayer  # Звук перезарядки

func _ready():
	ammo = max_ammo
	fire_timer.wait_time = fire_rate
	fire_timer.timeout.connect(_on_fire_timer_timeout)

	# Проверка, что bullet_scene назначен
	if not bullet_scene:
		push_error("bullet_scene не назначен! Пожалуйста, назначьте префаб пули в редакторе.")

# Устанавливаем цель (игрока)
func set_target(new_target: Node2D):
	target = new_target
	if target:
		fire_timer.start()  # Запускаем стрельбу, если цель есть
	else:
		fire_timer.stop()  # Останавливаем стрельбу, если цель потеряна

# Обработка таймера стрельбы
func _on_fire_timer_timeout():
	if target and not reloading:
		_shoot()

# Логика стрельбы
func _shoot():
	if not target:  # Проверяем, что цель существует
		return

	if ammo > 0:
		if not bullet_scene:
			push_error("bullet_scene не назначен! Невозможно создать пулю.")
			return

		var bullet = bullet_scene.instantiate()
		if bullet:
			bullet.shooter = self  # Устанавливаем shooter как врага
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = fire_point.global_position
			bullet.rotation = global_position.direction_to(target.global_position).angle()
			bullet.shoot()
			ammo -= 1

			if fire_sound:
				fire_sound.play()

		if ammo == 0:
			_reload()
	else:
		_reload()

# Логика перезарядки
func _reload():
	if reloading:
		return

	reloading = true
	if reload_sound:
		reload_sound.play()

	await get_tree().create_timer(reload_time).timeout

	ammo = max_ammo
	reloading = false

# Направляем оружие на цель
func _process(delta):
	if target:  # Проверяем, что цель существует
		look_at(target.global_position)

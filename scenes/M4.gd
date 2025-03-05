extends CanvasGroup

@export var bullet_scene: PackedScene # Префаб пули
@export var max_ammo: int = 30  # Максимальный боезапас
@export var reload_time: float = 2.0  # Время перезарядки
@export var fire_rate: float = 0.2  # Интервал между выстрелами

var ammo: int = max_ammo
var reloading: bool = false
var is_firing: bool = false  # Флаг для проверки, удерживается ли кнопка мыши

@onready var weapon = $Mka  # Оружие (Sprite2D)
@onready var fire_point = $Mka/Muzzle  # Точка появления пули (Marker2D)
@onready var ammo_sprite = $Mka/Ammo  # Спрайт патронов (Ammo)
@onready var fire_timer = $FireTimer  # Таймер для задержки между выстрелами

func _ready():
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.timeout.connect(_on_FireTimer_timeout)  # Подключаем сигнал таймера

func _process(_delta):
	weapon.look_at(get_global_mouse_position())  # Оружие поворачивается к курсору

func shoot():
	if ammo > 0 and not reloading:
		var bullet = bullet_scene.instantiate()  # Создаём экземпляр пули
		if bullet:  # Проверяем, что пуля была успешно создана
			get_tree().current_scene.add_child(bullet)  # Добавляем пулю в текущую сцену
			bullet.position = fire_point.to_global(Vector2.ZERO)  # Устанавливаем позицию пули
			bullet.rotation = weapon.rotation  # Устанавливаем угол пули
			bullet.shoot()  # Метод для движения пули
			ammo -= 1  # Уменьшаем количество патронов
		
		if ammo == 0:
			reload()

func reload():
	if not reloading:
		reloading = true
		ammo_sprite.hide()  # Прячем спрайт патронов
		
		await get_tree().create_timer(reload_time).timeout  # Ждём время перезарядки
		
		ammo = max_ammo
		reloading = false
		ammo_sprite.show()  # Показываем спрайт патронов обратно

func _input(event):
	# Если кнопка мыши нажата, начинаем стрельбу
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_firing = true
			if not fire_timer.is_stopped():  # Если таймер уже идёт, не запускаем его снова
				return
			fire_timer.start()  # Запускаем таймер стрельбы
			shoot()  # Первый выстрел без задержки
		else:
			is_firing = false
			fire_timer.stop()  # Останавливаем таймер, если отпустили кнопку

func _on_FireTimer_timeout():
	if is_firing and not reloading:  # Стрелять, если удерживается кнопка и не идёт перезарядка
		shoot()

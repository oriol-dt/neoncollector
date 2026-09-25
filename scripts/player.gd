extends CharacterBody2D

const SPEED = 300.0

# Variables para control táctil / ratón
var target_position: Vector2 = Vector2.ZERO
var is_touching: bool = false

func _ready() -> void:
	target_position = global_position

func _unhandled_input(event: InputEvent) -> void:
	# 1. Entrada en Pantalla Táctil (Móvil)
	if event is InputEventScreenTouch:
		is_touching = event.pressed
		if is_touching:
			target_position = event.position
			
	elif event is InputEventScreenDrag:
		if is_touching:
			target_position = event.position

	# 2. Entrada con Ratón (Para pruebas en PC con Clic + Arrastrar)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_touching = event.pressed
			if is_touching:
				target_position = event.position
				
	elif event is InputEventMouseMotion:
		if is_touching:
			target_position = event.position

func _physics_process(_delta: float) -> void:
	# Verificamos primero la entrada por teclado / mando
	var keyboard_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if keyboard_direction != Vector2.ZERO:
		# Si se usa teclado, anulamos el destino táctil
		is_touching = false
		velocity = keyboard_direction * SPEED
	elif is_touching:
		# Si hay un toque/arrastre táctil activo, movemos hacia target_position
		var distance = global_position.distance_to(target_position)
		
		# Margen mínimo (10px) para evitar temblores al llegar al punto final
		if distance > 10.0:
			var direction = global_position.direction_to(target_position)
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
	move_and_slide()
	_wrap_screen_edges()

func _wrap_screen_edges() -> void:
	var screen_size = get_viewport_rect().size
	
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0
		
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0

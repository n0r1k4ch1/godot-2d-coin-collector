extends CharacterBody2D

const SPEED = 420.0
const ACCELERATION = 2600.0
const FRICTION = 2200.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	# Nhận diện cả phím WASD và 4 phím mũi tên
	var input_direction = Vector2.ZERO
	
	if Input.is_physical_key_pressed(KEY_A) or Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_physical_key_pressed(KEY_W) or Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	
	# Gia tốc và ma sát mượt mà, phản hồi ngay lập tức
	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
		velocity = velocity.move_toward(input_direction * SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move_and_slide()

	# Giới hạn người chơi luôn nằm trong khung màn hình
	var screen_size = get_viewport_rect().size
	var radius = 32.0
	global_position.x = clamp(global_position.x, radius + 20.0, screen_size.x - radius - 20.0)
	global_position.y = clamp(global_position.y, radius + 20.0, screen_size.y - radius - 20.0)

	# Hiệu ứng xoay nghiêng và lật mặt nhân vật theo hướng di chuyển
	if sprite:
		if velocity.x < -15.0:
			sprite.flip_h = true
		elif velocity.x > 15.0:
			sprite.flip_h = false
		
		var target_rotation = clamp(velocity.x / SPEED * 0.12, -0.12, 0.12)
		sprite.rotation = lerp_angle(sprite.rotation, target_rotation, 14.0 * delta)

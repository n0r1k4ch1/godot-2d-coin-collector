extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_collected: bool = false
var float_offset: float = 0.0
var float_speed: float = 3.5
var time_alive: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Tạo độ lệch ngẫu nhiên để các đồng xu không nhấp nhô giống hệt nhau
	float_offset = randf_range(0.0, TAU)
	float_speed = randf_range(3.0, 4.0)
	
	# Hiệu ứng xuất hiện mượt mà (phóng to từ 0 với hiệu ứng nảy nhẹ)
	scale = Vector2.ZERO
	modulate.a = 0.0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, 0.25)

func _process(delta: float) -> void:
	if is_collected:
		return
	time_alive += delta
	# Hiệu ứng lơ lửng bồng bềnh
	if sprite:
		sprite.position.y = sin(time_alive * float_speed + float_offset) * 4.0

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	
	if body is CharacterBody2D:
		is_collected = true
		
		# Tắt va chạm lập tức để phản hồi tức thì và không bị nhặt 2 lần
		set_deferred("monitoring", false)
		if collision_shape:
			collision_shape.set_deferred("disabled", true)
		
		# Báo cho Scene chính xử lý điểm, âm thanh và hiệu ứng
		var main_scene = get_tree().current_scene
		if not main_scene or not (main_scene.has_method("on_coin_collected") or main_scene.has_method("add_score")):
			var p = get_parent()
			while p:
				if p.has_method("on_coin_collected") or p.has_method("add_score"):
					main_scene = p
					break
				p = p.get_parent()
		
		if main_scene:
			if main_scene.has_method("on_coin_collected"):
				main_scene.on_coin_collected(self, global_position)
			elif main_scene.has_method("add_score"):
				main_scene.add_score(1)
		
		# Hiệu ứng thu thập (phóng to nhẹ, bay lên và mờ dần trong 0.16s)
		var tween = create_tween().set_parallel(true)
		if sprite:
			tween.tween_property(sprite, "scale", sprite.scale * 1.35, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.tween_property(sprite, "modulate:a", 0.0, 0.16)
			tween.tween_property(sprite, "position:y", sprite.position.y - 12.0, 0.16)
		tween.chain().tween_callback(queue_free)

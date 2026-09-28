extends Node2D

const MAX_COINS: int = 5
const SPAWN_INTERVAL: float = 3.5

@onready var score_label: Label = $CanvasLayer/PanelContainer/MarginContainer/HBoxContainer/ScoreLabel
@onready var coins_info_label: Label = $CanvasLayer/CoinsInfoLabel
@onready var coins_container: Node2D = $CoinsContainer
@onready var player: CharacterBody2D = $CharacterBody2D
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var score: int = 0
var coin_scene: PackedScene = preload("res://coin.tscn")
var spawn_timer: Timer

func _ready() -> void:
	# Khởi tạo âm thanh ăn xu kiểu 8-bit arcade
	setup_audio()
	
	# Khởi tạo Timer sinh đồng xu có kiểm soát số lượng
	spawn_timer = Timer.new()
	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Sinh sẵn 3 đồng xu ban đầu ở các vị trí khác nhau
	for i in range(3):
		spawn_coin()
	
	update_ui()

func _on_spawn_timer_timeout() -> void:
	# Chỉ sinh thêm nếu chưa đạt giới hạn số lượng trên màn hình
	if get_coin_count() < MAX_COINS:
		spawn_coin()

func get_coin_count() -> int:
	if not coins_container:
		coins_container = get_node_or_null("CoinsContainer")
	if not coins_container:
		return 0
	var count = 0
	for child in coins_container.get_children():
		# Chỉ đếm những đồng xu chưa bị thu thập
		if child is Area2D and not child.get("is_collected"):
			count += 1
	return count

func spawn_coin() -> void:
	if get_coin_count() >= MAX_COINS:
		return
	
	if not coins_container:
		coins_container = get_node_or_null("CoinsContainer")
	
	var coin = coin_scene.instantiate()
	var screen_size = get_viewport_rect().size
	if screen_size == Vector2.ZERO:
		screen_size = Vector2(1152, 648)
	
	# Giới hạn trong vùng an toàn cách lề 80px
	var margin_x = 80.0
	var margin_y = 80.0
	var min_dist_from_player = 140.0
	var spawn_pos = Vector2.ZERO
	
	# Tìm vị trí ngẫu nhiên không quá gần người chơi (tối đa 15 lần thử)
	var player_pos = player.global_position if player else screen_size / 2.0
	var found_valid_pos = false
	for attempt in range(15):
		var test_pos = Vector2(
			randf_range(margin_x, screen_size.x - margin_x),
			randf_range(margin_y, screen_size.y - margin_y)
		)
		if test_pos.distance_to(player_pos) >= min_dist_from_player:
			spawn_pos = test_pos
			found_valid_pos = true
			break
	
	if not found_valid_pos:
		spawn_pos = Vector2(
			randf_range(margin_x, screen_size.x - margin_x),
			randf_range(margin_y, screen_size.y - margin_y)
		)
	
	coin.position = spawn_pos
	if coins_container:
		coins_container.add_child(coin)
	else:
		add_child(coin)
	update_ui()

func on_coin_collected(_coin: Area2D, coin_pos: Vector2) -> void:
	score += 1
	
	# Phát âm thanh ăn xu
	play_coin_sound()
	
	# Hiển thị số "+1" bay lên tại vị trí đồng xu
	show_floating_text("+1", coin_pos)
	
	# Hiệu ứng nảy (punch bounce) cho chữ Score
	animate_score_label()
	
	update_ui()
	
	# Nếu người chơi đã nhặt hết đồng xu, sinh ngay 1 đồng mới sau 0.8s
	if get_coin_count() == 0:
		get_tree().create_timer(0.8).timeout.connect(spawn_coin)

func add_score(amount: int) -> void:
	score += amount
	update_ui()

func update_ui() -> void:
	if score_label:
		score_label.text = "Score: " + str(score)
	if coins_info_label:
		coins_info_label.text = "Đồng xu: %d / %d" % [get_coin_count(), MAX_COINS]

func animate_score_label() -> void:
	if not score_label:
		return
	score_label.pivot_offset = score_label.size / 2.0
	var tween = create_tween()
	tween.tween_property(score_label, "scale", Vector2(1.3, 1.3), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(score_label, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func show_floating_text(text: String, pos: Vector2) -> void:
	var label = Label.new()
	label.text = text
	label.position = pos - Vector2(16, 24)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.25, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.12, 0.12, 0.12, 0.9))
	label.add_theme_constant_override("outline_size", 5)
	label.z_index = 10
	add_child(label)
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 35.0, 0.45).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.45).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)

func setup_audio() -> void:
	if not audio_player:
		audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
	
	# Tạo âm thanh synth chuông vàng kiểu retro B5 -> E6
	var wav = generate_coin_sound()
	audio_player.stream = wav
	audio_player.volume_db = -4.0

func play_coin_sound() -> void:
	if audio_player and audio_player.stream:
		audio_player.play()

func generate_coin_sound() -> AudioStreamWAV:
	var sample_rate = 22050
	var duration = 0.22
	var num_samples = int(sample_rate * duration)
	var data = PackedByteArray()
	data.resize(num_samples)
	
	var phase1 = 0.0
	var phase2 = 0.0
	var freq1 = 987.77 # B5
	var freq2 = 1318.51 # E6
	var split_sample = int(sample_rate * 0.065)
	
	for i in range(num_samples):
		var sample: float
		if i < split_sample:
			phase1 += freq1 / sample_rate
			sample = sin(phase1 * TAU) * 0.4
		else:
			var t_decay = float(i - split_sample) / (num_samples - split_sample)
			phase2 += freq2 / sample_rate
			var envelope = pow(1.0 - t_decay, 2.0)
			sample = sin(phase2 * TAU) * 0.45 * envelope
		
		# 8-bit unsigned PCM (0..255)
		data[i] = int(clamp((sample + 1.0) * 127.5, 0, 255))
	
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_8_BITS
	wav.mix_rate = sample_rate
	wav.data = data
	return wav

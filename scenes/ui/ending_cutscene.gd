extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var story_label: Label = $Panel/StoryLabel
@onready var continue_hint: Label = $ContinueHint
@onready var ending_choices_panel: Control = $EndingChoicesPanel
@onready var choice_1_button: Button = $EndingChoicesPanel/VBoxContainer/Choice1Button
@onready var choice_2_button: Button = $EndingChoicesPanel/VBoxContainer/Choice2Button

# =========================================================
# CONFIGURATION
# =========================================================
var TYPEWRITER_SPEED: float = 0.05
var FADE_DURATION: float = 0.8
var SKIP_ON_CLICK: bool = true

# =========================================================
# ENDING DATA
# =========================================================
var ending_cutscene_data = [
	{
		"image": preload("res://assets/ending/ship_working.png"),  # ⭐ PERLU ANDA PROVIDE
		"text": "Berkat bantuan Mbah Kucing dan kerja keras kami bersama, kapal akhirnya selesai diperbaiki!"
	},
	{
		"image": preload("res://assets/ending/ship_working.png"),
		"text": "Kapal itu akan membawaku ke petualangan baru... Tapi aku sudah mencintai pulau ini dan Mbah Kucing..."
	},
	{
		"image": preload("res://assets/ending/ship_working.png"),
		"text": "Ini adalah momen terpenting dalam hidupku. Harus memilih antara dua jalan yang berbeda..."
	}
]

# =========================================================
# VARIABLE INTERNAL
# =========================================================
var current_slide: int = 0
var is_typing: bool = false
var is_transitioning: bool = false
var current_text: String = ""
var display_text: String = ""
var typewriter_timer: float = 0.0
var can_advance: bool = false
var showing_choices: bool = false

func _ready() -> void:
	print("⭐ Ending Cutscene Started!")
	
	# Setup awal
	texture_rect.modulate.a = 0.0
	story_label.text = ""
	continue_hint.text = "[Click untuk lanjut]"
	continue_hint.modulate.a = 0.0
	ending_choices_panel.modulate.a = 0.0
	
	# Setup button signals
	choice_1_button.pressed.connect(_on_choice_1_selected)
	choice_2_button.pressed.connect(_on_choice_2_selected)
	
	# Tampilkan slide pertama
	show_slide(current_slide)

func _process(delta: float) -> void:
	# Proses typewriter effect
	if is_typing:
		typewriter_timer += delta
		
		while typewriter_timer >= TYPEWRITER_SPEED and display_text.length() < current_text.length():
			display_text += current_text[display_text.length()]
			story_label.text = display_text
			typewriter_timer = 0.0
		
		# Selesai typing
		if display_text.length() >= current_text.length():
			is_typing = false
			can_advance = true
			
			# Fade in continue hint untuk last slide, atau langsung show choices
			if current_slide == ending_cutscene_data.size() - 1:
				show_ending_choices()
			else:
				var tween = create_tween()
				tween.tween_property(continue_hint, "modulate:a", 1.0, 0.5)

func _input(event: InputEvent) -> void:
	if SKIP_ON_CLICK and (event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)):
		get_tree().root.get_child(0).get_tree().set_input_as_handled()
		
		if is_typing:
			skip_typewriter()
		elif can_advance and not showing_choices:
			next_slide()

# =========================================================
# TYPEWRITER LOGIC
# =========================================================

func skip_typewriter() -> void:
	"""Skip typewriter effect"""
	if is_typing:
		display_text = current_text
		story_label.text = display_text
		is_typing = false
		can_advance = true
		typewriter_timer = 0.0
		
		if current_slide == ending_cutscene_data.size() - 1:
			show_ending_choices()
		else:
			var tween = create_tween()
			tween.tween_property(continue_hint, "modulate:a", 1.0, 0.5)

func start_typewriter(text: String) -> void:
	"""Mulai typewriter effect"""
	current_text = text
	display_text = ""
	is_typing = true
	can_advance = false
	typewriter_timer = 0.0
	story_label.text = ""
	continue_hint.modulate.a = 0.0

# =========================================================
# SLIDE MANAGEMENT
# =========================================================

func show_slide(index: int) -> void:
	"""Tampilkan slide dengan fade in"""
	if index < 0 or index >= ending_cutscene_data.size():
		return
	
	current_slide = index
	is_transitioning = true
	
	# Fade out
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(texture_rect, "modulate:a", 0.0, FADE_DURATION / 2.0)
	fade_out_tween.tween_callback(func():
		texture_rect.texture = ending_cutscene_data[index]["image"]
		start_typewriter(ending_cutscene_data[index]["text"])
	)
	
	# Fade in
	var fade_in_tween = create_tween()
	fade_in_tween.tween_delay(FADE_DURATION / 2.0)
	fade_in_tween.tween_property(texture_rect, "modulate:a", 1.0, FADE_DURATION / 2.0)
	fade_in_tween.tween_callback(func():
		is_transitioning = false
	)

func next_slide() -> void:
	"""Lanjut ke slide berikutnya"""
	if is_transitioning:
		return
	
	current_slide += 1
	
	if current_slide < ending_cutscene_data.size():
		show_slide(current_slide)

# =========================================================
# ENDING CHOICES
# =========================================================

func show_ending_choices() -> void:
	"""Tampilkan pilihan ending setelah cutscene selesai"""
	if showing_choices:
		return
	
	showing_choices = true
	can_advance = false
	continue_hint.modulate.a = 0.0
	
	# Fade in panel dengan pilihan
	var tween = create_tween()
	tween.tween_property(ending_choices_panel, "modulate:a", 1.0, 1.0)
	
	# Enable buttons
	choice_1_button.disabled = false
	choice_2_button.disabled = false

func _on_choice_1_selected() -> void:
	"""Pilihan 1: Lanjut Menjelajah (Meninggalkan Pulau)"""
	print("✅ Ending Selected: CONTINUE EXPLORING (Meninggalkan Pulau)")
	
	# Disable buttons
	choice_1_button.disabled = true
	choice_2_button.disabled = true
	
	# Fade out dan trigger ending
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(texture_rect, "modulate:a", 0.0, 1.0)
	tween.tween_property(story_label, "modulate:a", 0.0, 1.0)
	tween.tween_property(ending_choices_panel, "modulate:a", 0.0, 1.0)
	
	tween.tween_callback(func():
		finish_game("continue_exploring")
	)

func _on_choice_2_selected() -> void:
	"""Pilihan 2: Tinggal dan Kembangkan Pulau Bersama Kakek"""
	print("✅ Ending Selected: STAY AND DEVELOP ISLAND (Tinggal Bersama)")
	
	# Disable buttons
	choice_1_button.disabled = true
	choice_2_button.disabled = true
	
	# Fade out dan trigger ending
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(texture_rect, "modulate:a", 0.0, 1.0)
	tween.tween_property(story_label, "modulate:a", 0.0, 1.0)
	tween.tween_property(ending_choices_panel, "modulate:a", 0.0, 1.0)
	
	tween.tween_callback(func():
		finish_game("stay_and_develop")
	)

# =========================================================
# GAME FINISH
# =========================================================

func finish_game(ending_type: String) -> void:
	"""Selesaikan game dengan ending yang dipilih"""
	print("🎮 Game Finished with ending: ", ending_type)
	
	# Update quest step
	QuestManager.quest_step = 10  # Mark as finished
	QuestManager.save_quest()
	
	# Bisa di-customize lebih lanjut:
	# - Tampilkan credits
	# - Save final game state
	# - Return to main menu
	# - Dll
	
	# Untuk sekarang, kembali ke main menu atau freeze game
	get_tree().paused = true
	print("🏁 Game Selesai! Type: ", ending_type)
	
	# Optional: Bisa uncomment untuk auto-kembali ke main menu setelah 3 detik
	# await get_tree().create_timer(3.0).timeout
	# get_tree().paused = false
	# get_tree().change_scene_to_file("res://scenes/main_menu.tscn")  # Jika ada main menu

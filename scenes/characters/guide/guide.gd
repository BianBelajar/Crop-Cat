extends Node2D

var balloon_scene = preload("res://dialogue/kakek_dialogue_balloon.tscn")

@onready var interactable_component: InteractabeComponent = $InteractableComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent

var in_range: bool

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	interactable_label_component.hide()
	
	GameDialogueManager.give_axe.connect(on_give_axe)
	GameDialogueManager.give_hoe.connect(on_give_hoe)
	GameDialogueManager.give_farming_kit.connect(on_give_farming_kit)
	
# Cek jika pemain baru pertama kali main DAN cutscene sudah beres
	if QuestManager.quest_step == 0 and QuestManager.is_intro_done == true:
		call_deferred("start_intro_dialogue")

# ---> TAMBAHKAN FUNGSI BARU INI DI BAWAH <---
func start_intro_dialogue() -> void:
	var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
	get_tree().root.add_child(balloon)
	# Memanggil naskah "intro", bukan "start"
	balloon.start(load("res://dialogue/conversations/mbah_kucing.dialogue"), "intro")


func on_interactable_activated() -> void:
	# Munculkan tombol 'E' saat pemain mendekat
	interactable_label_component.show()
	in_range = true


func on_interactable_deactivated() -> void:
	# Sembunyikan tombol 'E' saat pemain menjauh
	interactable_label_component.hide()
	in_range = false


func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("show_dialogue"):
			# ---> TAMBAHKAN BARIS INI SEBAGAI PENGAMAN <---
			get_viewport().set_input_as_handled() 
			
			var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
			get_tree().root.add_child(balloon)
			balloon.start(load("res://dialogue/conversations/mbah_kucing.dialogue"), "start")


# FUNGSI: Mengaktifkan Kapak
func on_give_axe() -> void:
	ToolManager.enable_tool_button(DataTypes.Tools.AxeWood)
	print("Kapak berhasil didapatkan!")

# FUNGSI: Mengaktifkan Pacul/Tilling
func on_give_hoe() -> void:
	ToolManager.enable_tool_button(DataTypes.Tools.TillGround)
	print("Sinyal Pacul diterima, tombol diaktifkan!")

# ---> FUNGSI BARU: Mengaktifkan Siraman & Bibit <---
func on_give_farming_kit() -> void:
	ToolManager.enable_tool_button(DataTypes.Tools.WaterCrops)
	ToolManager.enable_tool_button(DataTypes.Tools.PlantWheat)
	ToolManager.enable_tool_button(DataTypes.Tools.PlantTomato)
	print("Farming kit diterima! Siraman dan bibit menyala!")

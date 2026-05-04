# =============================================================================
# guide.gd  —  VERSI DIPERBARUI (Mbah Kucing)
# Lokasi: res://scenes/characters/guide/guide.gd
#
# PERUBAHAN dari versi asli:
#   • Tambah koneksi sinyal trigger_ending → on_trigger_ending()
#   • on_trigger_ending() memuat ending_cutscene.tscn
#   • Posisi Mbah Kucing TIDAK diubah — tetap di posisi scene seperti semula
# =============================================================================
extends Node2D

var balloon_scene = preload("res://dialogue/kakek_dialogue_balloon.tscn")
var ending_cutscene_scene = preload("res://scenes/ui/ending_cutscene.tscn")

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
	GameDialogueManager.trigger_ending.connect(on_trigger_ending)
	GameDialogueManager.start_ship_repair.connect(on_start_ship_repair)

	if QuestManager.quest_step == 0 and QuestManager.is_intro_done == true:
		call_deferred("start_intro_dialogue")

func start_intro_dialogue() -> void:
	var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
	get_tree().root.add_child(balloon)
	balloon.start(load("res://dialogue/conversations/mbah_kucing.dialogue"), "intro")

func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true

func on_interactable_deactivated() -> void:
	interactable_label_component.hide()
	in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("show_dialogue"):
			get_viewport().set_input_as_handled()
			var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
			get_tree().root.add_child(balloon)
			balloon.start(load("res://dialogue/conversations/mbah_kucing.dialogue"), "start")

func on_give_axe() -> void:
	ToolManager.enable_tool_button(DataTypes.Tools.AxeWood)
	print("✅ Kapak berhasil didapatkan!")

func on_give_hoe() -> void:
	ToolManager.enable_tool_button(DataTypes.Tools.TillGround)
	print("✅ Sinyal Pacul diterima, tombol diaktifkan!")

func on_give_farming_kit() -> void:
	ToolManager.enable_tool_button(DataTypes.Tools.WaterCrops)
	ToolManager.enable_tool_button(DataTypes.Tools.PlantWheat)
	ToolManager.enable_tool_button(DataTypes.Tools.PlantTomato)
	print("✅ Farming kit diterima! Siraman dan bibit menyala!")

func on_start_ship_repair() -> void:
	print("🚢 Quest Perbaikan Kapal aktif! Quest Step: ", QuestManager.quest_step)

func on_trigger_ending() -> void:
	print("🎬 Memuat Ending Cutscene...")
	var ending_scene = ending_cutscene_scene.instantiate()
	get_tree().root.add_child(ending_scene)

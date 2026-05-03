extends Node2D

# Ganti yang awalnya game_dialogue_balloon.tscn menjadi:
var balloon_scene = preload("res://dialogue/pedagang_dialogue_balloon.tscn")

@onready var interactable_component: InteractabeComponent = $InteractableComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent

var in_range: bool

func _ready() -> void:
	interactable_component.interactable_activated.connect(on_interactable_activated)
	interactable_component.interactable_deactivated.connect(on_interactable_deactivated)
	interactable_label_component.hide()
	
	# ---> TAMBAHKAN BARIS INI: Hubungkan sinyal unlock pestisida
	GameDialogueManager.unlock_pesticide.connect(on_unlock_pesticide)


func on_interactable_activated() -> void:
	interactable_label_component.show()
	in_range = true

func on_interactable_deactivated() -> void:
	interactable_label_component.hide()
	in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if in_range:
		if event.is_action_pressed("show_dialogue"):
			var balloon: BaseGameDialogueBalloon = balloon_scene.instantiate()
			get_tree().root.add_child(balloon)
			balloon.start(load("res://dialogue/conversations/pedagang.dialogue"), "start")

# ---> FUNGSI BARU: Mengaktifkan tombol Pestisida di UI
func on_unlock_pesticide() -> void:
	ToolManager.enable_tool_button(DataTypes.Tools.Pesticide)
	print("Pestisida berhasil diaktifkan oleh Pedagang!")

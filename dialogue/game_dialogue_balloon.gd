extends BaseGameDialogueBalloon

# PERBAIKI PATH INI SESUAI DENGAN SCENE TREE KAMU (Gunakan Copy Node Path)
@onready var emotes_panel: Panel = $Balloon/MarginContainer/PanelContainer/MarginContainer/HBoxContainer/EmotesPanel

func start(with_dialogue_resource: DialogueResource = null, title: String = "", extra_game_states: Array = []) -> void:
	# UBAH dialogue_resource MENJADI with_dialogue_resource
	super.start(with_dialogue_resource, title, extra_game_states) 
	emotes_panel.play_emote("emote_12_talking")

func next(next_id: String) -> void:
	super.next(next_id)
	emotes_panel.play_emote("emote_12_talking")

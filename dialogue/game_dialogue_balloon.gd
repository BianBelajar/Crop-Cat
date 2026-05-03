extends BaseGameDialogueBalloon

# Path ini sudah aku sesuaikan dengan gambar Scene Tree kamu
@onready var emotes_panel: Panel = $Balloon/MarginContainer/Control/VBoxContainer/PanelContainer/MarginContainer/HBoxContainer/EmotesPanel

func start(with_dialogue_resource: DialogueResource = null, title: String = "", extra_game_states: Array = []) -> void:
	super.start(with_dialogue_resource, title, extra_game_states) 
	if emotes_panel:
		emotes_panel.play_emote("emote_12_talking")

func next(next_id: String) -> void:
	super.next(next_id)
	if emotes_panel:
		emotes_panel.play_emote("emote_12_talking")

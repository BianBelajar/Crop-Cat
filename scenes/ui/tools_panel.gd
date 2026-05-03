extends PanelContainer

@onready var tool_axe: Button = $MarginContainer/HBoxContainer/ToolAxe
@onready var tool_tilling: Button = $MarginContainer/HBoxContainer/ToolTilling
@onready var tool_watering: Button = $MarginContainer/HBoxContainer/ToolWatering
@onready var tool_wheat: Button = $MarginContainer/HBoxContainer/ToolWheat
@onready var tool_tomato: Button = $MarginContainer/HBoxContainer/ToolTomato
# TAMBAHKAN INI:
@onready var tool_pesticide: Button = $MarginContainer/HBoxContainer/ToolPesticide

func _ready() -> void:
	ToolManager.enable_tool.connect(on_enable_tool_button)
	
	# ---> KONEKKAN SINYAL DARI QUEST MANAGER <---
	QuestManager.quest_loaded_signal.connect(update_tools_based_on_quest)
	
	# Panggil fungsi ini sekali saat game baru dimulai
	update_tools_based_on_quest()


# ---> KUMPULKAN LOGIKA NYALAIN ALAT DI FUNGSI BARU INI <---
func update_tools_based_on_quest() -> void:
	# 1. MATIKAN SEMUA ALAT DULU SECARA DEFAULT
	tool_axe.disabled = true
	tool_tilling.disabled = true
	tool_watering.disabled = true
	tool_wheat.disabled = true
	tool_tomato.disabled = true
	tool_pesticide.disabled = true
	
	tool_axe.focus_mode = Control.FOCUS_NONE
	tool_tilling.focus_mode = Control.FOCUS_NONE
	tool_watering.focus_mode = Control.FOCUS_NONE
	tool_wheat.focus_mode = Control.FOCUS_NONE
	tool_tomato.focus_mode = Control.FOCUS_NONE
	tool_pesticide.focus_mode = Control.FOCUS_NONE
	
	# 2. BUKA KUNCI OTOMATIS BERDASARKAN PROGRESS
	if QuestManager.quest_step >= 1: # Jika sudah dapat kapak
		tool_axe.disabled = false
		tool_axe.focus_mode = Control.FOCUS_ALL
		
	if QuestManager.quest_step >= 4: # Jika sudah dapat pacul, siraman & bibit
		tool_tilling.disabled = false
		tool_tilling.focus_mode = Control.FOCUS_ALL
		tool_watering.disabled = false
		tool_watering.focus_mode = Control.FOCUS_ALL
		tool_wheat.disabled = false
		tool_wheat.focus_mode = Control.FOCUS_ALL
		tool_tomato.disabled = false
		tool_tomato.focus_mode = Control.FOCUS_ALL
		
	if QuestManager.quest_step >= 6: # Jika sudah dapat pestisida
		tool_pesticide.disabled = false
		tool_pesticide.focus_mode = Control.FOCUS_ALL

# Fungsi saat tombol ditekan
func _on_tool_axe_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.AxeWood)

func _on_tool_tilling_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.TillGround)

func _on_tool_watering_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.WaterCrops)

func _on_tool_corn_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.PlantWheat)

func _on_tool_tomato_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.PlantTomato)

func _on_tool_pesticide_pressed() -> void:
	ToolManager.select_tool(DataTypes.Tools.Pesticide)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_tool"):
		ToolManager.select_tool(DataTypes.Tools.None)
		tool_axe.release_focus()
		tool_tilling.release_focus()
		tool_watering.release_focus()
		tool_wheat.release_focus()
		tool_tomato.release_focus()
		tool_pesticide.release_focus() # Tambahkan ini

# Logika untuk membuka kunci alat (dari Mbah Kucing)
func on_enable_tool_button(tool: DataTypes.Tools) -> void:
	if tool == DataTypes.Tools.AxeWood:
		tool_axe.disabled = false
		tool_axe.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.TillGround:
		tool_tilling.disabled = false
		tool_tilling.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.WaterCrops:
		tool_watering.disabled = false
		tool_watering.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.PlantWheat:
		tool_wheat.disabled = false
		tool_wheat.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.PlantTomato:
		tool_tomato.disabled = false
		tool_tomato.focus_mode = Control.FOCUS_ALL
	elif tool == DataTypes.Tools.Pesticide:
		tool_pesticide.disabled = false
		tool_pesticide.focus_mode = Control.FOCUS_ALL

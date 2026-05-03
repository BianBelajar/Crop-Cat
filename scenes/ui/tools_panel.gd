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
	
	# Matikan semua tombol di awal kecuali kapak (sesuai sistem tutorial)
	tool_axe.disabled = true
	tool_tilling.disabled = true
	tool_watering.disabled = true
	tool_wheat.disabled = true
	tool_tomato.disabled = true
	tool_pesticide.disabled = true # Pestisida juga mati di awal
	
	# Hilangkan fokus agar rapi
	tool_axe.focus_mode = Control.FOCUS_NONE
	tool_tilling.focus_mode = Control.FOCUS_NONE
	tool_watering.focus_mode = Control.FOCUS_NONE
	tool_wheat.focus_mode = Control.FOCUS_NONE
	tool_tomato.focus_mode = Control.FOCUS_NONE
	tool_pesticide.focus_mode = Control.FOCUS_NONE

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

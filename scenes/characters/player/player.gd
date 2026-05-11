class_name Player
extends CharacterBody2D

@onready var hit_components: HitComponent = $HitComponents

@export var current_tool: DataTypes.Tools = DataTypes.Tools.None

var player_direction : Vector2

func _ready() -> void:
	add_to_group("player")        # ← TAMBAH BARIS INI
	ToolManager.tool_selected.connect(on_tool_selected)

func on_tool_selected(tool: DataTypes.Tools) -> void:
	current_tool = tool 
	hit_components.current_tool = tool
	print("Tool", tool)

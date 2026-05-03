class_name HurtComponent
extends Area2D

@export var tool : DataTypes.Tools = DataTypes.Tools.None

signal hurt

func _on_area_entered(area: Area2D) -> void:
	var hit_component = area as HitComponent
	
	if hit_component == null:
		return
		
	# Bikin Godot lapor tiap kali ada alat yang nyentuh tanaman
	print("🔥 [HurtComponent] Kena sentuh area! Alat nomor: ", hit_component.current_tool)
	
	if tool == hit_component.current_tool:
		hurt.emit(hit_component.hit_damage)
		
	# Pintu khusus untuk Pestisida:
	elif hit_component.current_tool == DataTypes.Tools.Pesticide and get_parent().has_method("apply_pesticide"):
		print("💦 [HurtComponent] Pestisida diizinkan masuk! Ngasih sinyal hurt...")
		hurt.emit(hit_component.hit_damage)

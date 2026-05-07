# =============================================================================
# inventory_panel.gd  —  MODIFIKASI: Tambah tooltip hover
# =============================================================================
extends PanelContainer

@onready var log_label: Label = $MarginContainer/VBoxContainer/Logs/LogLabel
@onready var stone_label: Label = $MarginContainer/VBoxContainer/Stone/StoneLabel
@onready var wheat_label: Label = $MarginContainer/VBoxContainer/Wheat/WheatLabel
@onready var tomato_label: Label = $MarginContainer/VBoxContainer/Tomato/TomatoLabel
@onready var egg_label: Label = $MarginContainer/VBoxContainer/Egg/EggLabel
@onready var milk_label: Label = $MarginContainer/VBoxContainer/Milk/MilkLabel

# ── Referensi ke PARENT Container tiap item (bukan labelnya) ──────────────────
# Ganti nama sesuai nama node di scene-mu
@onready var slot_log:    Control = $MarginContainer/VBoxContainer/Logs
@onready var slot_stone:  Control = $MarginContainer/VBoxContainer/Stone
@onready var slot_wheat:  Control = $MarginContainer/VBoxContainer/Wheat
@onready var slot_tomato: Control = $MarginContainer/VBoxContainer/Tomato
@onready var slot_egg:    Control = $MarginContainer/VBoxContainer/Egg
@onready var slot_milk:   Control = $MarginContainer/VBoxContainer/Milk

# Peta slot → nama tampilan item
const SLOT_NAMES: Dictionary = {
	"Logs":   "Kayu",
	"Stone":  "Batu",
	"Wheat":  "Gandum",
	"Tomato": "Tomat",
	"Egg":    "Telur",
	"Milk":   "Susu",
}

func _ready() -> void:
	InventoryManager.inventory_changed.connect(on_inventory_changed)
	_connect_slot_hover_signals()

func _connect_slot_hover_signals() -> void:
	var slots = [slot_log, slot_stone, slot_wheat, slot_tomato, slot_egg, slot_milk]
	for slot in slots:
		if slot == null:
			continue
		# Aktifkan mouse filter agar bisa menerima sinyal mouse
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.mouse_entered.connect(_on_slot_mouse_entered.bind(slot.name))
		slot.mouse_exited.connect(_on_slot_mouse_exited)

func _on_slot_mouse_entered(slot_name: String) -> void:
	var display_name = SLOT_NAMES.get(slot_name, slot_name)
	ItemTooltip.show_tooltip(display_name)

func _on_slot_mouse_exited() -> void:
	ItemTooltip.hide_tooltip()

func on_inventory_changed() -> void:
	var inventory: Dictionary = InventoryManager.inventory

	if inventory.has("log"):
		log_label.text = str(inventory["log"])
	if inventory.has("stone"):
		stone_label.text = str(inventory["stone"])
	if inventory.has("wheat"):
		wheat_label.text = str(inventory["wheat"])
	if inventory.has("tomato"):
		tomato_label.text = str(inventory["tomato"])
	if inventory.has("egg"):
		egg_label.text = str(inventory["egg"])
	if inventory.has("milk"):
		milk_label.text = str(inventory["milk"])

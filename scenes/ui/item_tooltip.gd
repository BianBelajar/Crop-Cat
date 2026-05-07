# =============================================================================
# item_tooltip.gd  —  Tooltip nama item mengikuti kursor
# Lokasi: res://scenes/ui/item_tooltip.gd
# Pasang pada root node (CanvasLayer) dari item_tooltip.tscn
#
# Daftarkan sebagai AUTOLOAD di Project Settings dengan nama: ItemTooltip
# =============================================================================
extends CanvasLayer

@onready var tooltip_panel: PanelContainer = $TooltipPanel
@onready var tooltip_label: Label = $TooltipPanel/MarginContainer/TooltipLabel

const OFFSET = Vector2(14, 14)   # Jarak tooltip dari ujung kursor

func _ready() -> void:
	tooltip_panel.visible = false
	self.layer = 100

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.80)
	style.border_width_left   = 1
	style.border_width_right  = 1
	style.border_width_top    = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left     = 3
	style.corner_radius_top_right    = 3
	style.corner_radius_bottom_left  = 3
	style.corner_radius_bottom_right = 3
	# ✅ Margin lebih kecil
	style.content_margin_left   = 5
	style.content_margin_right  = 5
	style.content_margin_top    = 2
	style.content_margin_bottom = 2
	tooltip_panel.add_theme_stylebox_override("panel", style)

	tooltip_label.add_theme_color_override("font_color", Color.WHITE)
	# ✅ Font lebih kecil
	tooltip_label.add_theme_font_size_override("font_size", 11)
	tooltip_panel.visible = false
	# Pindahkan ke atas semua UI lain
	self.layer = 100

func _process(_delta: float) -> void:
	if tooltip_panel.visible:
		# Ikuti posisi mouse setiap frame
		tooltip_panel.global_position = get_viewport().get_mouse_position() + OFFSET
		_clamp_to_screen()

## Tampilkan tooltip dengan nama item tertentu.
func show_tooltip(item_name: String) -> void:
	tooltip_label.text = item_name
	tooltip_panel.visible = true

## Sembunyikan tooltip.
func hide_tooltip() -> void:
	tooltip_panel.visible = false

## Pastikan tooltip tidak keluar dari tepi layar.
func _clamp_to_screen() -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = tooltip_panel.size
	var pos = tooltip_panel.global_position

	if pos.x + panel_size.x > viewport_size.x:
		pos.x = viewport_size.x - panel_size.x - 4
	if pos.y + panel_size.y > viewport_size.y:
		pos.y = viewport_size.y - panel_size.y - 4

	tooltip_panel.global_position = pos

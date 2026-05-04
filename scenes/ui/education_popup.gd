# =============================================================================
# education_popup.gd
# Lokasi: res://scenes/ui/education_popup.gd
#
# Pasangkan script ini ke Node root scene education_popup.tscn
# (lihat panduan pembuatan scene di bawah komentar ini)
#
# STRUKTUR SCENE (buat manual di Godot):
# ─────────────────────────────────────
# CanvasLayer  (education_popup.tscn)
#   └─ PanelContainer  (name: Panel)
#        ├─ VBoxContainer
#        │    ├─ HBoxContainer
#        │    │    ├─ Label  (name: IconLabel)   → teks emoji/ikon
#        │    │    └─ Label  (name: TitleLabel)  → "Fakta Pertanian!"
#        │    ├─ HSeparator
#        │    └─ Label  (name: FactLabel)        → teks fakta
#        └─ Button  (name: CloseButton)          → "Oke, Mengerti!"
#
# PANDUAN INSPECTOR (StyleBoxFlat untuk Panel):
# ─────────────────────────────────────────────
# Pilih PanelContainer → Inspector → Theme Overrides → Styles → panel
#   Klik [buat baru] → StyleBoxFlat
#   • bg_color          : Color(0.13, 0.18, 0.12, 0.95)  ← hijau gelap transparan
#   • border_width_*    : 2 (semua sisi)
#   • border_color      : Color(0.40, 0.78, 0.35)        ← hijau cerah
#   • corner_radius_*   : 12 (semua sudut)
#   • content_margin_*  : 16
#
# PANDUAN INSPECTOR (StyleBoxFlat untuk CloseButton):
# ───────────────────────────────────────────────────
# Pilih CloseButton → Inspector → Theme Overrides → Styles
#   normal   → StyleBoxFlat: bg_color Color(0.22,0.55,0.20) corner_radius 8
#   hover    → StyleBoxFlat: bg_color Color(0.30,0.70,0.27) corner_radius 8
#   pressed  → StyleBoxFlat: bg_color Color(0.15,0.40,0.13) corner_radius 8
# Font → Theme Overrides → Font Sizes → font_size: 14
# =============================================================================
extends CanvasLayer

@onready var panel: PanelContainer         = $Panel
@onready var fact_label: Label             = $Panel/VBoxContainer/FactLabel
@onready var close_button: Button          = $Panel/CloseButton
@onready var title_label: Label            = $Panel/VBoxContainer/HBoxContainer/TitleLabel

# Durasi animasi masuk/keluar (detik)
const ANIM_DURATION: float = 0.35

func _ready() -> void:
	layer = 90                              # Di bawah cutscene (layer 100)
	close_button.pressed.connect(_on_close_pressed)
	panel.modulate = Color(1, 1, 1, 0)     # Mulai transparan
	panel.scale = Vector2(0.85, 0.85)       # Mulai sedikit kecil

## Tampilkan pop-up dengan teks fakta yang diberikan.
func show_fact(fact_text: String) -> void:
	fact_label.text = fact_text
	_animate_in()

func _animate_in() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 1), ANIM_DURATION)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), ANIM_DURATION) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_close_pressed() -> void:
	_animate_out()

func _animate_out() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(panel, "modulate", Color(1, 1, 1, 0), ANIM_DURATION * 0.7)
	tween.tween_property(panel, "scale", Vector2(0.85, 0.85), ANIM_DURATION * 0.7)
	# Tunggu sampai tween selesai lalu hapus node
	get_tree().create_timer(ANIM_DURATION * 0.7 + 0.05).timeout.connect(queue_free)

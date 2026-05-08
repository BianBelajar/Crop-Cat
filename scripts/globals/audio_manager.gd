## audio_manager.gd
## Autoload singleton untuk mengatur seluruh sistem audio game Crop-Cat.
## Daftarkan di: Project → Project Settings → Autoload
## Name: AudioManager | Path: res://scripts/globals/audio_manager.gd
extends Node

# ─── Konstanta Nama Bus ──────────────────────────────────────────
const BUS_MASTER := "Master"
const BUS_MUSIC  := "Music"
const BUS_SFX    := "SFX"

# ─── Kunci File Konfigurasi ──────────────────────────────────────
const SAVE_PATH          := "user://audio_settings.cfg"
const SAVE_KEY_MUSIC_VOL := "music_volume"
const SAVE_KEY_SFX_VOL   := "sfx_volume"

# ─── BGM Player ─────────────────────────────────────────────────
var _bgm_player: AudioStreamPlayer = null

# ─── Volume Properties (0.0 – 1.0) ──────────────────────────────
## Volume musik latar (0.0 = mute, 1.0 = penuh)
var music_volume: float = 1.0 :
	set(val):
		music_volume = clampf(val, 0.0, 1.0)
		_apply_bus_volume(BUS_MUSIC, music_volume)

## Volume efek suara (0.0 = mute, 1.0 = penuh)
var sfx_volume: float = 1.0 :
	set(val):
		sfx_volume = clampf(val, 0.0, 1.0)
		_apply_bus_volume(BUS_SFX, sfx_volume)


func _ready() -> void:
	# Load settings dulu sebelum buat player
	_load_audio_settings()

	# Buat BGM player global (tidak terikat posisi)
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	_bgm_player.bus = BUS_MUSIC
	add_child(_bgm_player)

	# Terapkan volume yang sudah di-load
	_apply_bus_volume(BUS_MUSIC, music_volume)
	_apply_bus_volume(BUS_SFX,   sfx_volume)

# Bisa dipanggil dari mana saja:
func show_audio_settings() -> void:
	var ui := preload("res://scenes/ui/audio_settings_ui.tscn").instantiate()
	get_tree().root.add_child(ui)

# ═════════════════════════════════════════════════════════════════
# BGM CONTROL
# ═════════════════════════════════════════════════════════════════

## Putar BGM. Jika stream sama sedang main, tidak restart.
## [param stream]      : AudioStream yang ingin diputar
## [param volume_db]   : Volume override dalam dB (default 0.0)
## [param from_start]  : Paksa restart meski stream sama
func play_bgm(stream: AudioStream, volume_db: float = 0.0, from_start: bool = false) -> void:
	if _bgm_player.stream == stream and _bgm_player.playing and not from_start:
		return
	_bgm_player.stream = stream
	_bgm_player.volume_db = volume_db
	_bgm_player.play()

## Hentikan BGM, dengan fade out opsional (dalam detik).
func stop_bgm(fade_duration: float = 0.0) -> void:
	if not _bgm_player.playing:
		return
	if fade_duration > 0.0:
		var tween := create_tween()
		tween.tween_property(_bgm_player, "volume_db", -80.0, fade_duration)
		await tween.finished
	_bgm_player.stop()
	_bgm_player.volume_db = 0.0

## Pause / resume BGM.
func pause_bgm(paused: bool) -> void:
	_bgm_player.stream_paused = paused

## Apakah BGM sedang diputar?
func is_bgm_playing() -> bool:
	return _bgm_player != null and _bgm_player.playing


# ═════════════════════════════════════════════════════════════════
# SFX CONTROL
# ═════════════════════════════════════════════════════════════════

## Putar SFX satu kali. Node otomatis dihapus setelah selesai.
## [param stream]   : AudioStream SFX
## [param position] : Posisi di dunia (default Vector2.ZERO = tidak positional)
## [param volume_db]: Volume override
func play_sfx(stream: AudioStream, position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> void:
	var player := AudioStreamPlayer2D.new()
	player.stream    = stream
	player.bus       = BUS_SFX
	player.position  = position
	player.volume_db = volume_db
	player.autoplay  = true
	get_tree().root.add_child(player)
	player.finished.connect(player.queue_free)


# ═════════════════════════════════════════════════════════════════
# VOLUME BUS CONTROL
# ═════════════════════════════════════════════════════════════════

## Konversi nilai linear (0.0–1.0) ke dB dan terapkan ke AudioServer.
func _apply_bus_volume(bus_name: String, linear_value: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		push_warning("AudioManager: Bus '%s' tidak ditemukan!" % bus_name)
		return
	if linear_value <= 0.001:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear_value))

## Ambil volume linear bus saat ini dari AudioServer.
func get_bus_volume_linear(bus_name: String) -> float:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx == -1:
		return 1.0
	if AudioServer.is_bus_mute(bus_idx):
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))


# ═════════════════════════════════════════════════════════════════
# PERSISTENSI SETTINGS
# ═════════════════════════════════════════════════════════════════

## Simpan pengaturan volume ke file konfigurasi.
func save_audio_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", SAVE_KEY_MUSIC_VOL, music_volume)
	config.set_value("audio", SAVE_KEY_SFX_VOL,   sfx_volume)
	var err := config.save(SAVE_PATH)
	if err != OK:
		push_warning("AudioManager: Gagal menyimpan settings! Error: %d" % err)

## Load pengaturan volume dari file konfigurasi.
func _load_audio_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		music_volume = config.get_value("audio", SAVE_KEY_MUSIC_VOL, 1.0)
		sfx_volume   = config.get_value("audio", SAVE_KEY_SFX_VOL,   1.0)
		print("AudioManager: Settings berhasil dimuat. Music=%.2f SFX=%.2f" % [music_volume, sfx_volume])
	else:
		# Default pertama kali
		music_volume = 1.0
		sfx_volume   = 1.0
		print("AudioManager: Settings baru, pakai default volume.")

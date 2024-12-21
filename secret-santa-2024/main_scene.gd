extends Node2D
@onready var health_bar: TextureProgressBar = $MainCharacter/Camera2D/HealthBar
@onready var xp_bar: TextureProgressBar = $MainCharacter/Camera2D/XPBar
@onready var main_character: CharacterBody2D = $MainCharacter
@onready var info: RichTextLabel = $MainCharacter/Camera2D/Info
const MUSIC_BASE = preload("res://audio/5. Odin's Whisper.mp3")
const MUSIC_BOSS = preload("res://audio/3. Saga of the Sea Wolves.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_info()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_info() -> void:
	info.text = "Level %d\nHP %d / %d\n XP %d / %d" % [main_character.level, main_character.hp, main_character.max_hp, main_character.xp, main_character.max_xp]

func _on_main_character_health_updated(new_value: Variant) -> void:
	update_info()
	health_bar.value = new_value
	health_bar.visible = true
	if new_value == 100.0:
		health_bar.visible = false

func enemy_died(xp: float) -> void:
	main_character.give_xp(xp)

func _on_main_character_xp_updated(new_value: Variant) -> void:
	update_info()
	xp_bar.value = new_value


func _on_boss_area_body_entered(body: Node2D) -> void:
	print("entererd")
	if body.name == "MainCharacter":
		$AudioStreamPlayer.stop()
		$AudioStreamPlayer.stream = MUSIC_BOSS
		$AudioStreamPlayer.play()

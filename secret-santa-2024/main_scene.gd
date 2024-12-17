extends Node2D
@onready var health_bar: TextureProgressBar = $MainCharacter/Camera2D/HealthBar
@onready var xp_bar: TextureProgressBar = $MainCharacter/Camera2D/XPBar
@onready var main_character: CharacterBody2D = $MainCharacter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_main_character_health_updated(new_value: Variant) -> void:
	health_bar.value = new_value
	health_bar.visible = true
	if new_value == 100.0:
		health_bar.visible = false

func enemy_died(xp: float) -> void:
	main_character.give_xp(xp)

func _on_main_character_xp_updated(new_value: Variant) -> void:
	xp_bar.value = new_value

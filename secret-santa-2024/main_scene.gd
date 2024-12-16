extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_main_character_health_updated(new_value: Variant) -> void:
	$MainCharacter/Camera2D/TextureProgressBar.value = new_value
	$MainCharacter/Camera2D/TextureProgressBar.visible = true
	if new_value == 100.0:
		$MainCharacter/Camera2D/TextureProgressBar.visible = false

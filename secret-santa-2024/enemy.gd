extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var hp = 10.0
@onready var animation: AnimatedSprite2D = $Animation

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func take_damage(damage: float) -> void:
	hp -= damage
	if hp > 0:
		animation.play("hurting")
	else:
		animation.play("dying")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animation.animation == "hurting":
		animation.play("default")
	elif animation.animation == "dying":
		queue_free()

extends CharacterBody2D

const SPEED = 50.0
const JUMP_VELOCITY = -400.0
var hp = 10.0
var direction = 1
var is_hurt = false
var is_attacking = false
@onready var animation: AnimatedSprite2D = $Animation

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if hp > 0 && !is_hurt && !is_attacking:
		velocity.x = SPEED * direction
		move_and_slide()
		if !$RayCast2D.is_colliding() && is_on_floor() || velocity.x == 0:
			scale.x = abs(scale.x) * -1
			direction = -direction
		if velocity.x != 0:
			animation.animation = "running"
		else:
			animation.animation = "default"
		for body in $AttackArea.get_overlapping_bodies():
			if body.name == "MainCharacter":
				is_attacking = true
				animation.play("attacking")
				break

func take_damage(damage: float) -> void:
	hp -= damage
	is_hurt = true
	is_attacking = false
	animation.play("hurting")

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		animation.play("default")
		is_attacking = false;
	if animation.animation == "hurting":
		is_hurt = false
		animation.play("default")
		if hp <= 0:
			animation.play("dying")
	elif animation.animation == "dying":
		queue_free()

func _on_attack_area_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "MainCharacter" && !is_hurt && hp > 0:
		is_attacking = true
		animation.play("attacking")

func _on_animation_frame_changed() -> void:
	if $Animation.animation == "attacking" && $Animation.frame == 7:
		for body in $AttackArea.get_overlapping_bodies():
			if body.name == "MainCharacter" && body.has_method("take_damage"):
				body.take_damage(5)

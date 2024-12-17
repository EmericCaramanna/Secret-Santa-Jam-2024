extends CharacterBody2D

const SPEED = 20.0
const JUMP_VELOCITY = -400.0
const MAX_HP = 10.0
const XP_TO_GIVE = 6.0

var hp = 10.0
var direction = 1

var is_hurt = false
var is_attacking = false

@onready var animation: AnimatedSprite2D = $Animation
@onready var health_bar: TextureProgressBar = $HealthBar

signal died(xp)

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
	if hp <= 0:
		return
	hp -= damage
	health_bar.visible = true
	health_bar.value = hp / MAX_HP * 100.0
	if hp <= 0:
		get_parent().enemy_died(XP_TO_GIVE)
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
	if body.name == "MainCharacter" && !is_hurt && hp > 0:
		is_attacking = true
		animation.play("attacking")

func _on_animation_frame_changed() -> void:
	if $Animation.animation == "attacking" && $Animation.frame == 7:
		for body in $AttackArea.get_overlapping_bodies():
			if body.name == "MainCharacter" && body.has_method("take_damage"):
				body.take_damage(5)

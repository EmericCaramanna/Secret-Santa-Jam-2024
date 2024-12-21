extends CharacterBody2D

const SPEED = 200.0
const SPEED_DURING_ATTACK = 30.0
const MOVE_TOWARD_SPEED = 25.0
const MOVE_TOWARD_SPEED_DASH = 200.0
const JUMP_VELOCITY = -400.0
const SPRITE_PIXEL_OFFSET: int = 7
const ATTACK_COLLISION_OFFSET: int = 25
const DASH_SPEED = 500.0
const BASE_DAMAGE = 5.0

@onready var animation: AnimatedSprite2D = $Animation
@onready var attack_collision: CollisionShape2D = $AttackArea/AttackCollision

var is_attacking = false
var is_hurting = false
var is_dashing = false

@export var max_hp = 10
@export var hp = max_hp
@export var max_xp = 10
@export var xp = 0
@export var level = 1

var spawn_position: Vector2

signal health_updated(new_value)
signal xp_updated(new_value)

func _ready() -> void:
	spawn_position = position

func level_up(xp_value: float) -> float:
	level += 1
	max_hp *= level
	hp = max_hp
	health_updated.emit(hp / max_hp * 100)
	var ret = xp - max_xp
	max_xp *= level
	return ret

func give_xp(xp_value: float) -> void:
	xp += xp_value
	if xp >= max_xp:
		xp = level_up(xp)
	xp_updated.emit(xp/max_xp * 100.0)

func dash() -> void:
	if Input.is_action_just_pressed("dash") && !is_dashing:
		is_dashing = true
		is_attacking = false
		if animation.flip_h:
			velocity = Vector2.LEFT * DASH_SPEED
		else:
			velocity = Vector2.RIGHT * DASH_SPEED
		animation.play("dashing")

func alive() -> void:
	if !is_attacking && !is_hurting && !is_dashing:
		if velocity.x != 0 && velocity.y == 0:
			animation.animation = "running"
		if velocity.x == 0 && velocity.y == 0:
			animation.animation = "default"
		if velocity.y < 0:
			animation.animation = "jumping"
		elif velocity.y > 0:
			animation.animation = "falling"
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("attack") && is_on_floor():
		if animation.animation == "attack" && animation.animation != "double_attack":
			var frame = animation.frame
			animation.animation = "double_attack"
			animation.frame = frame
		if !is_attacking:
			if !is_dashing:
				animation.animation = "attack"
			else:
				animation.play("dash_attacking")
		is_attacking = true
	if !is_dashing:
		var direction := Input.get_axis("left", "right")
		if direction:
			if !is_attacking && !is_hurting:
				velocity.x = direction * SPEED
			else:
				velocity.x = direction * SPEED_DURING_ATTACK
		else:
			velocity.x = move_toward(velocity.x, 0, MOVE_TOWARD_SPEED)
	dash()
	move_and_slide()

func sound_handler() -> void:
	match animation.animation:
		"running":
			if animation.frame == 2:
				if !$Step1.playing:
					$Step1.play()
			elif animation.frame == 6:
				if !$Step2.playing:
					$Step2.play()
		"attack":
			if !$Attack1.playing && animation.frame == 2:
				$Attack1.play()
		"double_attack":
			if !$Attack2.playing && animation.frame == 8:
				$Attack2.play()
		"dashing":
			if !$Dash.playing && animation.frame == 1:
				$Dash.play()
		"dash_attacking":
			if !$Attack2.playing && animation.frame == 2:
				$Attack2.play()

func _physics_process(delta: float) -> void:
	if hp > 0:
		alive()
	if !is_on_floor():
		velocity += get_gravity() * delta
	if velocity.x < 0:
		animation.flip_h = true;
		animation.position.x = -SPRITE_PIXEL_OFFSET
		attack_collision.position.x = -ATTACK_COLLISION_OFFSET
	if velocity.x > 0:
		animation.flip_h = false;
		animation.position.x = SPRITE_PIXEL_OFFSET
		attack_collision.position.x = ATTACK_COLLISION_OFFSET
	sound_handler()

func take_damage(damage: float) -> void:
	if hp <= 0:
		return
	if is_dashing && animation.frame < 4:
		return
	hp -= damage
	health_updated.emit(hp/max_hp * 100)
	if hp > 0:
		animation.play("hurting")
		is_hurting = true
		is_attacking = false
	else:
		animation.play("dying")

func attack() -> void:
	for area in $AttackArea.get_overlapping_bodies():
		if area.has_method("take_damage"):
			area.take_damage(BASE_DAMAGE * level)

func _on_animation_animation_finished() -> void:
	if hp > 0:
		if is_attacking || is_hurting || is_dashing:
			if is_dashing:
				velocity.x = 0
			animation.play("default")
			is_attacking = false
			is_hurting = false
			is_dashing = false
	if animation.animation == "dying":
		get_tree().reload_current_scene()

func _on_animation_frame_changed() -> void:
	if is_attacking && ((animation.frame == 5 || animation.frame == 9) || (is_dashing && animation.frame == 3)):
		attack()

func respawn_character() -> void:
	position = spawn_position
	is_attacking = false
	is_hurting = false
	is_dashing = false
	hp = max_hp
	health_updated.emit(100)
	animation.play("default")

func _on_dash_timer_timeout() -> void:
	print("end")
	animation.play("default")

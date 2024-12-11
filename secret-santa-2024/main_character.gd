extends CharacterBody2D


const SPEED = 300.0
const SPEED_DURING_ATTACK = 30.0
const MOVE_TOWARD_SPEED = 25.0
const JUMP_VELOCITY = -400.0
@onready var animation: AnimatedSprite2D = $Animation
const sprite_pixels_offset: int = 7;
var is_attacking = false;

func _physics_process(delta: float) -> void:
	if !is_attacking:
		if velocity.x != 0 && velocity.y == 0:
			animation.animation = "running"
		if velocity.x == 0 && velocity.y == 0:
			animation.animation = "default"
		if velocity.y < 0:
			animation.animation = "jumping"
		elif velocity.y > 0:
			animation.animation = "falling"

	# Add the gravity.
	if !is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") && is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_just_pressed("attack") && is_on_floor():
		if animation.animation == "attack" && animation.animation != "double_attack":
			var frame = animation.frame
			animation.animation = "double_attack"
			animation.frame = frame
		if !is_attacking:
			animation.animation = "attack"
		is_attacking = true
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		if !is_attacking:
			velocity.x = direction * SPEED
		else:
			velocity.x = direction * SPEED_DURING_ATTACK
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_TOWARD_SPEED)

	move_and_slide()
	if velocity.x < 0:
		animation.flip_h = true;
		animation.position.x = -sprite_pixels_offset;
	if velocity.x > 0:
		animation.flip_h = false;
		animation.position.x = sprite_pixels_offset;


func _on_animation_animation_finished() -> void:
	if is_attacking:
		animation.play("default")
		is_attacking = false;

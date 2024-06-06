@icon("res://Arts/heroes/knight/weapon_sword_1.png")

extends Node2D
class_name Weapon

@export var on_floor : bool = false

@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var ChargeParticle : GPUParticles2D = get_node("Node2D/Sprite/ChargeParticles")
@onready var hitbox : Area2D = get_node("Node2D/Sprite/Hitbox")
@onready var weapon : Node2D = $"."
@onready var PlayerDetector : Area2D = get_node("PlayerDetector")

func _ready() -> void:
	if not on_floor:
		PlayerDetector.set_collision_mask_value(1, false)
		PlayerDetector.set_collision_mask_value(2, false)

func get_input() -> void: #入力の受付
	if Input.is_action_just_pressed("UI_Attack") and not animation_player.is_playing():
		animation_player.play("charge") #攻撃の入力した後にアニメーション再生
	elif Input.is_action_just_released("UI_Attack"):
		if animation_player.is_playing() and animation_player.current_animation == "charge":
			animation_player.play("attack")
		elif ChargeParticle.emitting:
			animation_player.play("strong_attack")

func move(mouse_direction : Vector2) -> void:
	if not animation_player.is_playing() or animation_player.current_animation == "charge":
		weapon.rotation = mouse_direction.angle()
		hitbox.knockback_direction = mouse_direction
		if weapon.scale.y == 1 and mouse_direction.x < 0:
			weapon.scale.y = -1
		elif weapon.scale.y == -1 and mouse_direction.x > 0:
			weapon.scale.y = 1

func cancel_attack() -> void:
	animation_player.play("RESET")

func is_busy() -> bool:
	if animation_player.is_playing() or ChargeParticle.emitting:
		return true
	return false

func _on_player_detector_body_entered(_body : CharacterBody2D) -> void:
	if _body != null:
		PlayerDetector.set_collision_mask_value(1, true)
		PlayerDetector.set_collision_mask_value(2, true)
		_body.pick_up_weapon(self)
		position = Vector2.ZERO

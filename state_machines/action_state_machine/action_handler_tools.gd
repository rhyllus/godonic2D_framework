extends ActionStateMachine
class_name ActionHandlerTools

@onready var hitbox = player.get_node("CollisionShape2D")

@onready var forward = sprite.get_node("Forward")
@onready var forward_origin = sprite.get_node("ForwardOrigin")

@onready var sprt_snap = player.get_node("SpriteSnap")
@onready var sprt_center = sprt_snap.get_node("SpriteSnapCenter")
@onready var sprt_left = sprt_snap.get_node("SpriteSnapLeft")
@onready var sprt_right = sprt_snap.get_node("SpriteSnapRight")

@export var max_velocity := 2000
@export var acceleration := 1500
@export var deceleration := 2000

var sprite_flipped := false
var snap_velocity := Vector2.ZERO

func manage_wall_velocity():
	if player_X_velocity > 0 and right_wall.is_colliding():
		player_X_velocity = 0
	elif player_X_velocity < 0 and left_wall.is_colliding():
		player_X_velocity = 0

func sprite_flip():
	if horizontal_input != 0:
		if horizontal_input > 0:
			sprite_flipped = false
			sprite.scale.x = 1
		else:
			sprite_flipped = true
			sprite.scale.x = -1
			
func rotated_velocity(x_vel : float):
	var direction = (forward.global_position - forward_origin.global_position).normalized()
	if sprite_flipped:
		direction = -direction
	return x_vel * direction

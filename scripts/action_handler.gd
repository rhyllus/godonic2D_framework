extends ActionStateMachine
class_name ActionHandler

@export var max_velocity := 100000
@export var acceleration := 1000
@export var deceleration := 2000
@onready var normal := Vector2(0, -1)
var sprite_flipped := false

func velocity_rotated(x_vel : int):
	var forward = sprite.get_node("Forward")
	var forward_origin = sprite.get_node("ForwardOrigin")
	var direction = (forward.global_position - forward_origin.global_position).normalized()
	if sprite_flipped:
		direction = -direction
	return x_vel * direction

func wall_velocity_management():
	if player_X_velocity > 0 and right_wall.is_colliding():
		player_X_velocity = 0
	elif player_X_velocity < 0 and left_wall.is_colliding():
		player_X_velocity = 0

func horizontal_movement(delta):
	player_X_velocity = player_X_velocity + (acceleration * delta * horizontal_input)
	player_X_velocity = clampf(player_X_velocity, -max_velocity, max_velocity)
	wall_velocity_management()
	angle_calc()
	player.velocity =  velocity_rotated(player_X_velocity)

func decelerate(delta):
	wall_velocity_management()
	player_X_velocity = move_toward(player_X_velocity, 0, deceleration * delta)
	if player_X_velocity == 0:
		state = States.IDLE
		animation_player.play("idle")
		player.velocity = Vector2.ZERO
	else:
		player.velocity = velocity_rotated(player_X_velocity)
	angle_calc()

func roll():
	pass

func jump():
	pass
	
func hurt():
	pass

func sprite_flip():
	if horizontal_input != 0:
		if horizontal_input > 0:
			sprite_flipped = false
			sprite.scale.x = 1
		else:
			sprite_flipped = true
			sprite.scale.x = -1

func update(delta):
	if right_wall.is_colliding() or left_wall.is_colliding():
		wall_hit.emit()
	state_update()
	sprite_flip()
	if state == States.RUN or state == States.WALK:
		horizontal_movement(delta)
	elif state == States.DECEL:
		decelerate(delta)
	elif state == States.ROLL:
		roll()
	elif state == States.AIR:
		jump()
	elif state == States.HURT:
		hurt()

func flip_gravity():
	pass

func _on_wall_hit():
	var angle_diff := 0.0
	var right_wall_colliding = right_wall.is_colliding()
	if state == States.RUN or state == States.WALK:
		if right_wall_colliding:
			angle_diff = last_normal.angle_to(right_wall.get_collision_normal())
		else:
			angle_diff = last_normal.angle_to(left_wall.get_collision_normal())
	if abs(rad_to_deg(angle_diff)) < 85:
		if ground_direction == GroundDirections.DOWN:
			if right_wall_colliding:
				ground_direction = GroundDirections.RIGHT
			else:
				ground_direction = GroundDirections.LEFT
		else:
			ground_direction = GroundDirections.UP
		flip_gravity()

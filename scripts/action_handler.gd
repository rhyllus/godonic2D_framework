extends ActionHandlerTools
class_name ActionHandler

@export var max_velocity := 2000
@export var acceleration := 1500
@export var deceleration := 2000
@onready var normal := Vector2(0, -1)

func velocity_rotate(x_vel : int):
	var direction = (forward.global_position - forward_origin.global_position).normalized()
	if sprite_flipped:
		direction = -direction
	return x_vel * direction

func horizontal_movement(delta):
	player_X_velocity = player_X_velocity + (acceleration * delta * horizontal_input)
	player_X_velocity = clampf(player_X_velocity, -max_velocity, max_velocity)
	if abs(player_X_velocity) == max_velocity:
		state = States.RUN
		animation_player.play("run")
	manage_wall_velocity()
	ground_collision()
	player.velocity = velocity_rotate(player_X_velocity) + snap_velocity

func decelerate(delta):
	player_X_velocity = move_toward(player_X_velocity, 0, deceleration * delta)
	manage_wall_velocity()
	if player_X_velocity == 0:
		state = States.IDLE
		animation_player.play("idle")
		player.velocity = Vector2.ZERO
	else:
		ground_collision()
		player.velocity = velocity_rotate(player_X_velocity) + snap_velocity

func roll():
	pass

func jump():
	pass
	
func hurt():
	pass

func update(delta):
	if right_wall.is_colliding() or left_wall.is_colliding():
		wall_hit.emit()
	else:
		snap()
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
		
func _on_wall_hit():
	on_wall_hit()

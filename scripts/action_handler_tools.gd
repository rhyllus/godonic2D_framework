extends ActionStateMachine
class_name ActionHandlerTools

@onready var collider = player.get_node("CollisionShape2D")
@onready var sprt_center = collider.get_node("SpriteSnapCenter")
@onready var sprt_left = collider.get_node("SpriteSnapLeft")
@onready var sprt_right = collider.get_node("SpriteSnapRight")

var sprite_flipped := false
var snap_velocity := Vector2.ZERO

func angle_calc():
	var angle := 0.0
	if left.is_colliding():
		last_normal = left.get_collision_normal()
		if right.is_colliding() and (snapped(abs(last_normal.angle_to(player.up_direction)), 0.01) == snapped(PI, 0.01)):
			sprite.global_position = sprt_center.global_position
		else:
			sprite.global_position = sprt_left.global_position
		angle = last_normal.angle_to(Vector2(0, -1))
		sprite.rotation = -angle
	else:
		last_normal = right.get_collision_normal()
		if left.is_colliding() and (snapped(abs(last_normal.angle_to(player.up_direction)), 0.01) == snapped(PI, 0.01)):
			sprite.global_position = sprt_center.global_position
		else:
			sprite.global_position = sprt_right.global_position
		angle = last_normal.angle_to(Vector2(0, -1))
		sprite.rotation = -angle
	if angle == 0.0:
		sprite.global_position = sprt_center.global_position
	return angle

func wall_velocity_management():
	if player_X_velocity > 0 and right_wall.is_colliding():
		player_X_velocity = 0
	elif player_X_velocity < 0 and left_wall.is_colliding():
		player_X_velocity = 0

func snap():
	var snap_vector := Vector2.ZERO
	if left_snap.is_colliding() and not right.is_colliding():
		snap_vector = left_snap.get_collision_point() - sprt_left.global_position
	elif right_snap.is_colliding() and not left.is_colliding():
		snap_vector = right_snap.get_collision_point() - sprt_right.global_position
	snap_velocity = snap_vector * get_process_delta_time() * 5000

func sprite_flip():
	if horizontal_input != 0:
		if horizontal_input > 0:
			sprite_flipped = false
			sprite.scale.x = 1
		else:
			sprite_flipped = true
			sprite.scale.x = -1

func flip_gravity():
	if ground_direction == GroundDirections.RIGHT:
		raycasts.rotation_degrees = -90
		raycasts.position.x = -5
		collider.position.x = -5
		collider.rotation_degrees = -90
		player.up_direction = Vector2.RIGHT
	if ground_direction == GroundDirections.DOWN:
		raycasts.rotation_degrees = 0
		raycasts.position.x = 0
		collider.position.x = 0
		collider.rotation_degrees = 0
		player.up_direction = Vector2.DOWN
	for i in raycasts.get_children():
		i.force_raycast_update()

func on_wall_hit():
	var angle_diff := 0.0
	var right_wall_colliding = right_wall.is_colliding()
	if state == States.RUN or state == States.WALK or state == States.DECEL:
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
			elif ground_direction == GroundDirections.RIGHT:
				if right_wall_colliding:
					ground_direction = GroundDirections.UP
				else:
					ground_direction = GroundDirections.DOWN
			elif ground_direction == GroundDirections.LEFT:
				if right_wall_colliding:
					ground_direction = GroundDirections.DOWN
				else:
					ground_direction = GroundDirections.UP
			elif ground_direction == GroundDirections.UP:
				if right_wall_colliding:
					ground_direction = GroundDirections.LEFT
				else:
					ground_direction = GroundDirections.RIGHT
			flip_gravity()

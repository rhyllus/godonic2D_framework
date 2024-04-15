extends ActionStateMachine
class_name ActionHandlerTools

@onready var hitbox = player.get_node("CollisionShape2D")

@onready var forward = sprite.get_node("Forward")
@onready var forward_origin = sprite.get_node("ForwardOrigin")

@onready var sprt_snap = player.get_node("SpriteSnap")
@onready var sprt_center = sprt_snap.get_node("SpriteSnapCenter")
@onready var sprt_left = sprt_snap.get_node("SpriteSnapLeft")
@onready var sprt_right = sprt_snap.get_node("SpriteSnapRight")

var sprite_flipped := false
var snap_velocity := Vector2.ZERO

func is_ground_ray_collision_successful():
	if left.is_colliding():
		last_normal = left.get_collision_normal()
		if snapped(abs(last_normal.angle_to(player.up_direction)), 0.01) == snapped(PI, 0.01):
			sprite.global_position = sprt_center.global_position
		elif snapped(abs(last_normal.angle_to(player.up_direction)), 0.01) == 0.0:
			sprite.global_position = sprt_center.global_position
		else:
			sprite.global_position = sprt_left.global_position
		return true
	elif right.is_colliding():
		last_normal = right.get_collision_normal()
		if snapped(abs(last_normal.angle_to(player.up_direction)), 0.01) == snapped(PI, 0.01):
			sprite.global_position = sprt_center.global_position
		elif snapped(abs(last_normal.angle_to(player.up_direction)), 0.01) == 0.0:
			sprite.global_position = sprt_center.global_position
		else:
			sprite.global_position = sprt_right.global_position
		return true
	return false

func ground_collision():
	var collision_angle = 0.0
	if is_ground_ray_collision_successful():
		collision_angle = last_normal.angle_to(Vector2(0, -1))
		sprite.rotation = -collision_angle
	else:
		var old_pos := Vector2(left.target_position.y, right.target_position.y)
		left.target_position.y = 25
		right.target_position.y = 25
		left.force_raycast_update()
		right.force_raycast_update()
		if is_ground_ray_collision_successful():
			collision_angle = last_normal.angle_to(Vector2(0, -1))
			sprite.rotation = -collision_angle
		left.target_position.y = old_pos.x
		right.target_position.y = old_pos.y
		left.force_raycast_update()
		right.force_raycast_update()
	return

func manage_wall_velocity():
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
	else:
		if player_X_velocity > 0.0:
			snap_vector = left_snap.get_collision_point() - sprt_left.global_position
		elif player_X_velocity < 0.0:
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
		hitbox.position.x = -5
		sprt_snap.position.x = -5
		hitbox.shape.size.y = 20
		hitbox.shape.size.x = 28
		sprt_snap.rotation_degrees = -90
		player.up_direction = Vector2.RIGHT
	elif ground_direction == GroundDirections.LEFT:
		raycasts.rotation_degrees = 90
		raycasts.position.x = 5
		hitbox.position.x = 5
		sprt_snap.position.x = 5
		hitbox.shape.size.y = 20
		hitbox.shape.size.x = 28
		sprt_snap.rotation_degrees = 90
		player.up_direction = Vector2.LEFT
	elif ground_direction == GroundDirections.DOWN:
		raycasts.rotation_degrees = 0
		raycasts.position.x = 0
		hitbox.position.x = 0
		sprt_snap.position.x = 0
		hitbox.shape.size.y = 28
		hitbox.shape.size.x = 20
		sprt_snap.rotation_degrees = 0
		player.up_direction = Vector2.DOWN
	elif ground_direction == GroundDirections.UP:
		if raycasts.rotation_degrees == -90:
			raycasts.rotation_degrees = -180
		else:
			raycasts.rotation_degrees = 180
		raycasts.position.x = 0
		hitbox.position.x = 0
		sprt_snap.position.x = 0
		hitbox.shape.size.y = 28
		hitbox.shape.size.x = 20
		sprt_snap.rotation_degrees = -180
		player.up_direction = Vector2.UP
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
			if right_wall_colliding:
				if ground_direction == GroundDirections.UP:
					ground_direction = GroundDirections.LEFT
				else:
					ground_direction = GroundDirections[GroundDirections.keys()[ground_direction + 1]]
			else:
				if ground_direction == GroundDirections.LEFT:
					ground_direction = GroundDirections.UP
				else:
					ground_direction = GroundDirections[GroundDirections.keys()[ground_direction - 1]]
			flip_gravity()

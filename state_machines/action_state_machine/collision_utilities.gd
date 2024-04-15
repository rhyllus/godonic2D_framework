extends ActionHandlerTools
class_name CollisionUtilities

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
	elif ground_direction == GroundDirections.DOWN or ground_direction == GroundDirections.UP:
		raycasts.position.x = 0
		hitbox.position.x = 0
		sprt_snap.position.x = 0
		hitbox.shape.size.y = 28
		hitbox.shape.size.x = 20
		if ground_direction == GroundDirections.DOWN:
			raycasts.rotation_degrees = 0
			sprt_snap.rotation_degrees = 0
			player.up_direction = Vector2.DOWN
		else:
			if raycasts.rotation_degrees == -90:
				raycasts.rotation_degrees = -180
			else:
				raycasts.rotation_degrees = 180
			sprt_snap.rotation_degrees = -180
			player.up_direction = Vector2.UP
	for i in raycasts.get_children():
		i.force_raycast_update()

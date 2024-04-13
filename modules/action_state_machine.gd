extends Node
class_name ActionStateMachine

enum States {HURT, IDLE, DECEL, WALK, RUN,
			 SPINDASH, PEEL_OUT, POST_PEEL_OUT, ROLL,
			 AIR_BALL, AIR}
enum GroundDirections {UP, DOWN, LEFT, RIGHT}
@onready var state := States.AIR
@onready var ground_direction := GroundDirections.DOWN

@export var player : CharacterBody2D
@export var sprite : Node2D
@onready var animation_player : AnimationPlayer = sprite.get_node("Sprite2D").get_node("AnimationPlayer")

@onready var left = player.get_node("Raycasts").get_node("LeftDown")
@onready var right = player.get_node("Raycasts").get_node("RightDown")
@onready var right_wall = player.get_node("Raycasts").get_node("RightWall")
@onready var left_wall = player.get_node("Raycasts").get_node("LeftWall")

signal wall_hit

var last_normal : Vector2
var horizontal_input := 0.0
var player_X_velocity := 0.0

func _ready():
	animation_player.play("ball")

func ground_check():
	if left.is_colliding() or right.is_colliding():
		return true

func snap():
	pass
		
func angle_calc():
	var angle := 0.0
	if left.is_colliding() and right.is_colliding():
		sprite.rotation = 0
		sprite.position = Vector2.ZERO
		return angle
	elif left.is_colliding():
		sprite.position = Vector2(-10, 0)
		last_normal = left.get_collision_normal()
		angle = last_normal.angle_to(Vector2(0, -1))
		sprite.rotation = -angle
	else:
		sprite.position = Vector2(10, 0)
		last_normal = right.get_collision_normal()
		angle = last_normal.angle_to(Vector2(0, -1))
		sprite.rotation = -angle
	if angle == 0.0:
		sprite.position = Vector2.ZERO
	return angle

func state_update():
	horizontal_input = Input.get_axis("left", "right")
	if ground_check():
		player.apply_floor_snap()
		if state == States.AIR or state == States.AIR_BALL:
			if horizontal_input != 0.0:
				if player_X_velocity > 10000:
					state = States.RUN
					animation_player.play("run")
				else:
					state = States.WALK
					animation_player.play("walk")
			else:
				state = States.IDLE
				animation_player.play("idle")
		elif state == States.RUN or state == States.WALK:
			if horizontal_input == 0.0:
				state = States.DECEL
			elif Input.is_action_just_pressed("crouch"):
				state = States.ROLL
				animation_player.play("ball")
		elif state == States.IDLE or state == States.DECEL:
			if horizontal_input != 0.0:
				state = States.WALK
				animation_player.play("walk")
	else:
		player.apply_floor_snap()
		left.force_raycast_update()
		right.force_raycast_update()
		#state = States.AIR

extends Node
class_name ActionStateMachine

enum States {HURT, IDLE, DECEL, WALK, RUN, ROLL,
			 SPINDASH, PEEL_OUT, POST_PEEL_OUT,
			 AIR_BALL, AIR}
enum GroundDirections {UP, DOWN, LEFT, RIGHT}
@onready var state := States.AIR
@onready var ground_direction := GroundDirections.DOWN

@export var player : CharacterBody2D
@export var sprite : Node2D
@onready var animation_player : AnimationPlayer = sprite.get_node("Sprite2D").get_node("AnimationPlayer")

@onready var raycasts = player.get_node("Raycasts")
@onready var left = raycasts.get_node("LeftFloor")
@onready var left_snap = raycasts.get_node("LeftSnap")
@onready var right = raycasts.get_node("RightFloor")
@onready var right_snap = raycasts.get_node("RightSnap")
@onready var center_snap = raycasts.get_node("CenterSnap")
@onready var right_wall = raycasts.get_node("RightWall")
@onready var left_wall = raycasts.get_node("LeftWall")

signal wall_hit

var last_normal : Vector2
var horizontal_input := 0.0
var player_X_velocity := 0.0

func _ready():
	animation_player.play("ball")

func ground_check():
	if left.is_colliding() or right.is_colliding():
		return true

func state_update():
	horizontal_input = Input.get_axis("left", "right")
	if ground_check():
		if state == States.AIR or state == States.AIR_BALL:
			if player.velocity.x != 0.0:
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
		pass
		#state = States.AIR

extends Node2D

@onready var player = $CharacterBody2D
@onready var state_machine = $StateMachine
@onready var action_state_machine

func _physics_process(delta):
	state_machine.update_all(delta)
	player.move_and_slide()
	queue_redraw()
	
func _draw():
	var player_position := Vector2(player.position)
	player_position.y -= 12
	draw_line((player.velocity * 0.1) + player_position, player_position, Color.GREEN, 1.0)

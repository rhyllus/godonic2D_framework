extends Node
class_name StateMachine

var state_machines : Dictionary = {}

func _ready():
	for i in get_children():
		state_machines[i.name] = i

func update_all(delta):
	for machine in state_machines.values():
		machine.update(delta)

func change_state(machine_key : String, state_key : String):
	if state_machines.has(machine_key):
		var machine = state_machines.get(machine_key)
		machine.state = machine.States[state_key]
	else:
		print("MACHINE DOESN'T EXIST")

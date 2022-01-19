extends Control
signal hit_element

export var SEAL_AMOUNT = 5

const seal_input = preload("res://src/elements/seal_input.res")
const seal_history = preload("res://src/elements/seal_history.res")

var STATE = "running"

var answer = []
var input = []
var history = []
var tries = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	SEAL_AMOUNT = Global.STAGE_PARAM[0]
	$box/Label.text += " ("+str(Global.STAGE_PARAM[0])+" Seal)"
	_set_answer()
	var seals = [1,2,3,4,5,6]
	for seal in seals:
		get_node("box/HBoxContainer/seal_"+str(seal)).connect("pressed", self, "_on_press_seal", [seal])
	for n in range(10):
		var obj = seal_history.instance()
		obj.name = "history_"+str(n)
		$history/.add_child(obj)

func _set_answer():
	var prev = 0
	var ans = 0
	for nil in range(SEAL_AMOUNT):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		ans = rng.randi_range(1,6)
		while ans == prev:
			ans = rng.randi_range(1,6)
		prev = ans
		answer.append(ans)
	print(answer)

func _on_press_seal(seal_type):
	if (len(input) < SEAL_AMOUNT and (tries < 10 and STATE == "running")):
		var n = len(input)
		input.append(seal_type)
		
		var newInput = seal_input.instance()
		newInput.name = "seal_"+str(n)
		$input_box/.add_child(newInput)
		var new_obj = "input_box/seal_"+str(n)
		get_node(new_obj).texture = load("res://assets/Kekai/"+str(input[n])+".png")
	_check_submit()

func _check_submit():
	if len(input) < SEAL_AMOUNT:
		get_node("box/submit").disabled = true
	else:
		get_node("box/submit").disabled = false

func _on_submit_seal():
	if tries < 10:
		var check = _answer_check(input)
		history.append(input)
		_on_clear_seal()
		var record = get_node("history/history_"+str(tries))
		for n in range(len(history[tries])):
			var seal_type = history[tries][n]
			record.get_node('his_'+str(n)).visible = true
			record.get_node('his_'+str(n)).texture = load("res://assets/Kekai/"+str(seal_type)+".png")
		record.get_node('correct').text = str(check[0])
		record.get_node('partial').text = str(check[1])
		if (check[0] == SEAL_AMOUNT):
			STATE = "finished"
			_on_finish()
		tries +=1
	if (tries+1 > 10):
		$result/Label.text = "FAILED"
		$result.visible = true

func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

func _answer_check(input):
	var correct = 0
	var partial = 0
	for n in range(len(array_unique(input))):
		var value = input[n]
		if answer.has(value):
			partial+=1
	for n in range(len(input)):
		var value = input[n]
		if answer[n] == value:
			correct +=1
			partial -=1
	if (partial < 0):
		partial = 0
	return [correct,partial]

func _on_clear_seal():
	input=[]
	_check_submit()
	for child in $input_box/.get_children():
		child.free()


func _on_Result_pressed():
	get_tree().change_scene("res://src/scene/main.tscn")

func _on_finish():
	$box/submit.visible = false
	$animated_pass.playing = true
	$animated_pass.visible = true


func _on_pass_animation_finished():
	$result/Label.text = "SUCCESS"
	$result.visible = true

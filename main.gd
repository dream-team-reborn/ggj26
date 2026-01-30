extends Control

var dialogues: Dictionary
var selected: Variant

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _setup() -> void:
	var file = FileAccess.open("res://dialog.json", FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		print(error)
		return
	
	for dialogue in json.data:
		dialogues[dialogue["id"]] = dialogue
	
	selected = json.data[0]["id"]
	_setup_dialogue()

func _setup_dialogue() -> void:
	%Panel.visible = false
	%Choiche.visible = false
	%Choiche1.visible = false
	%Choiche2.visible = false
	%Choiche3.visible = false
	%Choiche4.visible = false
	
	var dialogue = dialogues[selected]
	
	if dialogue.has("music"):
		%AudioStreamPlayer.stream = load("res://assets/music/" + dialogue["music"])
		%AudioStreamPlayer.autoplay = true
	
	if dialogue.has("image"):
		%TextureRect.texture = load("res://assets/images/" + dialogue["image"])
	
	if dialogue.has("main"):
		%MainDialogueLabel.text = dialogue["main"]
		
	if dialogue.has("actions"):
		for index in range(len(dialogue["actions"])):
			match index:
				0:
					%Choiche1.visible = true
					%Choiche1Label.text = dialogue["actions"][index]["text"]
				1:
					%Choiche2.visible = true
					%Choiche2Label.text = dialogue["actions"][index]["text"]
				2:
					%Choiche3.visible = true
					%Choiche3Label.text = dialogue["actions"][index]["text"]
				3:
					%Choiche4.visible = true
					%Choiche4Label.text = dialogue["actions"][index]["text"]
					
	if dialogue.has("panel"):
		%Panel.visible = true
		%PanelLabel.text = dialogue["panel"]["text"]

func _next_dialogue(action: int) -> void:
	var dialogue = dialogues[selected]
	if not dialogue.has("end"):
		if dialogue.has("actions"):
			if not %Choiche.visible:
				%Choiche.visible = true
			elif action >= 0:
				selected = dialogue["actions"][action]["next"]
				_setup_dialogue()
		elif dialogue.has("next"):
			selected = dialogue["next"]
			_setup_dialogue()
		else:
			print("Dialogue wrong format cannot go next or set choiche")
	else:
		_setup()

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_type() and event.is_pressed():
		_next_dialogue(-1)

func _on_choiche_1_gui_input(event: InputEvent) -> void:
	if event.is_action_type() and event.is_pressed():
		_next_dialogue(0)

func _on_choiche_2_gui_input(event: InputEvent) -> void:
	if event.is_action_type() and event.is_pressed():
		_next_dialogue(1)

func _on_choiche_3_gui_input(event: InputEvent) -> void:
	if event.is_action_type() and event.is_pressed():
		_next_dialogue(2)

func _on_choiche_4_gui_input(event: InputEvent) -> void:
	if event.is_action_type() and event.is_pressed():
		_next_dialogue(3)

func _on_panel_gui_input(event: InputEvent) -> void:
	if event.is_action_type() and event.is_pressed():
		_next_dialogue(-1)

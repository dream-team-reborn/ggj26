extends Control

var dialogues: Dictionary
var selected: Variant
var points: int 

var menu = load("res://menu.tscn")

var is_playing_text: bool = false
var last_letter_delta: float = 0
var playback_index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dialogue = dialogues[selected]
	
	if is_playing_text and last_letter_delta > 0.05:
		last_letter_delta = 0
		if dialogue.has("panel"):
			if len(dialogue["panel"]) > playback_index:
				%PanelLabel.text += dialogue["panel"][playback_index]
				playback_index += 1
			else:
				is_playing_text = false
				playback_index = 0

			
		if dialogue.has("main"):
			if len(dialogue["main"]) > playback_index:
				%MainDialogueLabel.text += dialogue["main"][playback_index]
				playback_index += 1
			else:
				is_playing_text = false
				playback_index = 0
	elif is_playing_text:
		last_letter_delta += delta

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
	%Title.visible = false
	%Panel.visible = false
	%Choiche.visible = false
	%Choiche1.visible = false
	%Choiche2.visible = false
	%Choiche3.visible = false
	%Choiche4.visible = false
	
	var dialogue = dialogues[selected]
	
	if dialogue.has("music"):
		%Music.stream = load("res://assets/music/" + dialogue["music"])
		%Music.playing = true
		%Music.autoplay = true
		
	if dialogue.has("sound"):
		%Sound.stream = load("res://assets/sounds/" + dialogue["sound"])
		%Sound.playing = true
		%Sound.autoplay = false
	
	if dialogue.has("image"):
		%TextureRect.texture = load("res://assets/images/" + dialogue["image"])
	
	if dialogue.has("main"):
		%MainDialogueLabel.text = ""
		is_playing_text = true
		last_letter_delta = 0
		playback_index = 0
		
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
		%PanelLabel.text = ""
		is_playing_text = true
		last_letter_delta = 0
		playback_index = 0
		
	if dialogue.has("title"):
		%Title.visible = true
		%TitleLabel.text = dialogue["title"]

func _next_dialogue(action: int) -> void:
	var dialogue = dialogues[selected]
	if not dialogue.has("end"):
		if dialogue.has("actions"):
			if not %Choiche.visible:
				%Choiche.visible = true
			elif action >= 0:
				selected = dialogue["actions"][action]["next"]
				if dialogue["actions"][action].has("points"):
					points += dialogue["actions"][action]["points"]
				_setup_dialogue()
		elif dialogue.has("conditions"):
			var selection = null
			for condition in dialogue["conditions"]:
				if condition.has("next"):
					if condition.has("more") and condition["more"] > points:
						selection = condition["next"]
					elif condition.has("less") and condition["less"] <= points:
						selection = condition["next"]
					elif condition.has("equal") and condition["equal"] == points:
						selection = condition["next"]
			if selection:
				selected = selection
				_setup_dialogue()
		elif dialogue.has("next"):
			selected = dialogue["next"]
			_setup_dialogue()
		else:
			print("Dialogue wrong format cannot go next or set choiche")
	else:
		get_tree().change_scene_to_packed(menu)

func _on_gui_input(event: InputEvent) -> void:
	var input = event as InputEventMouseButton
	if input == null:
		return
		
	if input.button_index == 1 and input.is_pressed():
		if not is_playing_text:
			_next_dialogue(-1)
		else:
			var dialogue = dialogues[selected]
			if dialogue.has("panel"):
				%PanelLabel.text += dialogue["panel"].substr(playback_index, -1)

			if dialogue.has("main"):
				%MainDialogueLabel.text += dialogue["main"].substr(playback_index, -1)
			is_playing_text = false
			playback_index = 0

func _on_choiche_1_gui_input(event: InputEvent) -> void:
	var input = event as InputEventMouseButton
	if input == null:
		return
		
	if not is_playing_text and input.button_index == 1 and input.is_pressed():
		_next_dialogue(0)

func _on_choiche_2_gui_input(event: InputEvent) -> void:
	var input = event as InputEventMouseButton
	if input == null:
		return
		
	if not is_playing_text and input.button_index == 1 and input.is_pressed():
		_next_dialogue(1)

func _on_choiche_3_gui_input(event: InputEvent) -> void:
	var input = event as InputEventMouseButton
	if input == null:
		return
		
	if not is_playing_text and input.button_index == 1 and input.is_pressed():
		_next_dialogue(2)

func _on_choiche_4_gui_input(event: InputEvent) -> void:
	var input = event as InputEventMouseButton
	if input == null:
		return
		
	if not is_playing_text and input.button_index == 1 and input.is_pressed():
		_next_dialogue(3)

func _on_panel_gui_input(event: InputEvent) -> void:
	var input = event as InputEventMouseButton
	if input == null:
		return
		
	if input.button_index == 1 and input.is_pressed():
		if not is_playing_text:
			_next_dialogue(-1)
		else:
			var dialogue = dialogues[selected]
			if dialogue.has("panel"):
				%PanelLabel.text += dialogue["panel"].substr(playback_index, -1)

			if dialogue.has("main"):
				%MainDialogueLabel.text += dialogue["main"].substr(playback_index, -1)
			is_playing_text = false
			playback_index = 0

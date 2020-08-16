extends Control

onready var dialog = $PageVBox/PageHBox/DialogVBox/DialogScroll/Dialog/Margin/VBox
onready var choices = $PageVBox/PageHBox/ChoicesVBox/Choices/Margin/VBox

var spinner : YarnSpinner
var needlework : YarnNeedlework

var last_character = null

func _ready():
	needlework = MyYarnNeedlework.new()
	needlework.scene = self
	
	spinner = YarnSpinner.new()
	spinner.set_needlework(needlework)
	spinner.load('res://data/scene-example.yarn.txt')

func _process(delta):
	while spinner.can_spin():
		spinner.spin()

func create_dialog(character: String, line: String) -> void:
	if last_character != null and last_character != character:
		add_separator(dialog)

	var label = Label.new()
	if not character.empty():
		label.set_text('[%s] %s' % [character, line])
	else:
		label.set_text(line)
	label.autowrap = true
	dialog.add_child(label)

	last_character = character
	# hack to autoscroll vbox
	$PageVBox/PageHBox/DialogVBox/DialogScroll.scroll_vertical = 10000
	
func create_choice(text, marker):
	var button = Button.new()
	button.set_text(text)
	button.connect('pressed', self, 'on_choice_press', [marker])
	choices.add_child(button)
	
func on_choice_press(node_name):
	# clear old choices
	for child in choices.get_children():
		child.queue_free()
	last_character = null
	add_separator(dialog)
	spinner.pick(node_name)

func jump_to(node_name):
	last_character = null
	add_separator(dialog)
	spinner.pick(node_name)

func add_separator(to):
	if to.get_child_count()>0:
		var separator = HSeparator.new()
		to.add_child(separator)

func set_visit_label(text):
	$PageVBox/Bottom/VBoxContainer/VisitLabel.set_text(text)

extends "res://yarn/yarn-importer.gd"

# An example extended class of "yarn-importer"
#
# It is recommended you create your own based on this example.
#
# It is easier to just tie "yarn-importer" directly into your scene,
#  but in time you will likely reuse this class many times, 
#  and it can grow overly complicated merged in your scene
# You might also have multiple types of story GUIs, 
#  then you'd want one of these for each type of GUI

func connect_scene(parent):
	.set_scene(parent)

func yarn_text_variables(text):
	# TODO Support actual expressions.
	if text.find('{$') != -1:
		text = text.replace('{$name}', game.data['name'])
	return text

func story_setting(setting, value):
	pass

func say(character, line):
	scene.create_dialog(character, line)
	
func choice(text, node_name):
	scene.create_choice(text, node_name)

func jump(node_name):
	scene.jump_to(node_name)

func command(text) -> bool:
	if .command(text):
		return true
	else:
		return false
	
func action(text):
	pass

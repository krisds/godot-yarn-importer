extends YarnNeedlework

class_name MyYarnNeedlework

# An example extended class of "yarn-importer"
#
# It is recommended you create your own based on this example.
#
# It is easier to just tie "yarn-importer" directly into your scene,
#  but in time you will likely reuse this class many times, 
#  and it can grow overly complicated merged in your scene
# You might also have multiple types of story GUIs, 
#  then you'd want one of these for each type of GUI

func handle_inline_expressions(text):
	# TODO Support actual expressions.
	if text.find('{$') != -1:
		text = text.replace('{$name}', game.data['name'])
	return text

func say(character, line):
	scene.create_dialog(character, line)
	
func choose(labels: Array) -> void:
	for i in range(0, labels.size()):
		scene.create_choice(labels[i], i)

func jump(node_name):
	scene.jump_to(node_name)

func command(text) -> bool:
	if .command(text):
		return true
	else:
		return false
	
func action(text):
	pass

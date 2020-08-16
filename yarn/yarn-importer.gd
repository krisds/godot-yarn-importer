extends Node
#
# A YARN Importer for Godot
#
# Credits: 
# - Dave Kerr (http://www.naturallyintelligent.com)
# - KrisDS
# 
# Latest: https://github.com/naturally-intelligent/godot-yarn-importer
# This fork: https://github.com/krisds/godot-yarn-importer
# 
# Yarn: https://github.com/InfiniteAmmoInc/Yarn
# Twine: http://twinery.org
#
# Yarn syntax reference: https://yarnspinner.dev/docs/syntax/

var yarn_script : YarnScript

var locked = false
var node = null
var next_step = 0

var scene
func set_scene(parent):
	scene = parent

# OVERRIDE METHODS
#
# called to request new dialog
func say(character: String, line: String) -> void:
	pass
	
# called to request new choice button
func choice(text: String, node_name: String) -> void:
	pass

# called to jump to target node
func jump(node_name: String) -> void:
	pass

# called to handle commands
func command(text: String) -> bool:
	text = text.strip_edges()
	if text.begins_with('wait'):
		var time_sec : float = 1.0
		
		text = text.substr(4).strip_edges()
		if not text.empty():
			time_sec = float(text)
		
		lock()
		yield(scene.get_tree().create_timer(time_sec), "timeout")
		unlock()

		return true
	else:
		return false
	
# called for each line of text
func yarn_text_variables(text: String) -> String:
	return text
	
# called when "settings" node parsed
func story_setting(setting, value):
	pass
	
# START SPINNING YOUR YARN
#
func spin_yarn(file):
	yarn_script = YarnScript.new()
	yarn_script.load(file)
	# Find the starting node...
	node = yarn_script.get_node(yarn_script.start_node_name)

# Main logic for node handling
#
func yarn_unravel(to: String) -> void:
	node = yarn_script.get_node(to)
	next_step = 0

func can_step() -> bool:
	return not locked and node != null and next_step < node.body.size()

func step() -> void:
	if not can_step(): return
	var action : YarnAction = node.body[next_step]
	next_step += 1
	match action.kind:
		YarnAction.Type.DIALOGUE:
			var text : String = yarn_text_variables(action.text)
			say(action.character, text)
		YarnAction.Type.OPTION:
			var text : String = yarn_text_variables(action.text)
			choice(text, action.to_node_name)
		YarnAction.Type.JUMP:
			jump(action.to_node_name)
		YarnAction.Type.COMMAND:
			command(action.text)
	
func lock():
	locked = true

func unlock():
	locked = false


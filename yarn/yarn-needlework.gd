class_name YarnNeedlework

# TODO Should pass via methods instead ?
var spinner

# TODO Cleaner solution ?
var scene

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
		
		spinner.lock()
		yield(scene.get_tree().create_timer(time_sec), "timeout")
		spinner.unlock()

		return true
	else:
		return false
	
# called for each line of text
func handle_inline_expressions(text: String) -> String:
	return text

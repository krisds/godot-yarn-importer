class_name YarnSpinner

var yarn_script : YarnScript
var needlework : YarnNeedlework

var locked = false
var node = null
var next_step = 0

func set_needlework(_needlework: YarnNeedlework) -> void:
	needlework = _needlework
	needlework.spinner = self

func load(file):
	yarn_script = YarnScript.new()
	yarn_script.load(file)
	# Find the starting node...
	node = yarn_script.get_node(yarn_script.start_node_name)

func pick(to: String) -> void:
	node = yarn_script.get_node(to)
	next_step = 0

func can_spin() -> bool:
	return not locked and node != null and next_step < node.body.size()

func spin() -> void:
	if not can_spin(): return
	var action : YarnAction = node.body[next_step]
	next_step += 1
	match action.kind:
		YarnAction.Type.DIALOGUE:
			var text : String = needlework.handle_inline_expressions(action.text)
			needlework.say(action.character, text)
		YarnAction.Type.OPTION:
			var text : String = needlework.handle_inline_expressions(action.text)
			needlework.choice(text, action.to_node_name)
		YarnAction.Type.JUMP:
			needlework.jump(action.to_node_name)
		YarnAction.Type.COMMAND:
			needlework.command(action.text)
	
func lock():
	locked = true

func unlock():
	locked = false


class_name YarnSpinner

var yarn_script : YarnScript
var needlework : YarnNeedlework

var locked = false
var node : YarnNode = null
var blocks_stack : Array = []
var statement_counters : Array = []
var branches : Array = []

func set_needlework(_needlework: YarnNeedlework) -> void:
	needlework = _needlework
	needlework.spinner = self

func load(file) -> void:
	yarn_script = YarnScript.new()
	yarn_script.load(file)

	# Find the starting node...
	node = yarn_script.get_node(yarn_script.start_node_name)

	blocks_stack = [node.body]
	statement_counters = [0]

func pick(to: int) -> void:
	var statement = branches[to]

	if statement is YarnOption:
		goto(statement.to_node_name)
		
	elif statement is YarnShortcutOption:
		if not statement.empty():
			blocks_stack.append(statement)
			statement_counters.append(0)

	else:
		print('[ERROR] Unexpected statement type')

	branches = []
	unlock()

func goto(node_name: String) -> void:
	node = yarn_script.get_node(node_name)
	blocks_stack = [node.body]
	statement_counters = [0]

func _manage_stack():
	while blocks_stack.size() > 1 and statement_counters[-1] >= blocks_stack[-1].statement_count():
		blocks_stack.pop_back()
		statement_counters.pop_back()


func can_spin() -> bool:
	_manage_stack()
	return not locked and node != null and statement_counters[-1] < blocks_stack[-1].statement_count()

func spin() -> void:
	if not can_spin(): return
	
	var statement : YarnStatement = blocks_stack[-1].get_statement(statement_counters[-1])
	
	if statement is YarnDialogue:
		var text : String = needlework.handle_inline_expressions(statement.text)
		needlework.say(statement.character, text)
		statement_counters[-1] += 1
	
	elif statement is YarnOption:
		# Add the first choice
		branches.append(statement)
		statement_counters[-1] += 1
		# Add following choices
		while statement_counters[-1] < blocks_stack[-1].statement_count() and blocks_stack[-1].get_statement(statement_counters[-1]) is YarnOption:
			branches.append(blocks_stack[-1].get_statement(statement_counters[-1]))
			statement_counters[-1] += 1
		
		var labels : Array = []
		for option in branches:
			labels.append(needlework.handle_inline_expressions(option.text))

		needlework.choose(labels)
		# Wait for the user's choice.
		lock()
	
	elif statement is YarnJump:
		needlework.jump(statement.to_node_name)
		statement_counters[-1] += 1
	
	elif statement is YarnCommand:
		needlework.command(statement.text)
		statement_counters[-1] += 1
	
	elif statement is YarnShortcutOption:
		# Add the first choice
		branches.append(statement)
		statement_counters[-1] += 1
		# Add following choices
		while statement_counters[-1] < blocks_stack[-1].statement_count() and blocks_stack[-1].get_statement(statement_counters[-1]) is YarnShortcutOption:
			branches.append(blocks_stack[-1].get_statement(statement_counters[-1]))
			statement_counters[-1] += 1
		
		var labels : Array = []
		for option in branches:
			labels.append(needlework.handle_inline_expressions(option.text))

		needlework.choose(labels)
		# Wait for the user's choice.
		lock()
	
func lock() -> void:
	locked = true

func unlock() -> void:
	locked = false

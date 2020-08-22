class_name YarnScript

var nodes : Dictionary = {}
var start_node_name : String
var path: String

func _add_node(node: YarnNode) -> void:
	nodes[node.header['title']] = node
	if not start_node_name:
		start_node_name = node.header['title']

func get_node(name: String) -> YarnNode:
	if nodes.has(name):
		return nodes[name]
	else:
		return null

# Create Yarn data structure from file (must be *.yarn.txt Yarn format)
func load(_path) -> void:
	path = _path
	var file := File.new()
	file.open(path, file.READ)
	
	if not file.is_open():
		print('ERROR: Yarn file missing: ', path)
		return

	# yarn reading flags
	var header := true
	var node := YarnNode.new()
	var line_number := 0
	
	# loop
	while !file.eof_reached():
		var blocks  = [node.body]
		var indents = [0]
		
		# read a line
		var line := file.get_line()
		line_number += 1
		
		# Skip empty lines and comments
		var stripped_line = line.strip_edges()
		if stripped_line.empty() and stripped_line.begins_with('//'):
			continue
		
		if header:
			if line == '---':
				header = false
				if not node.header.has('title'):
					print('[ERROR] Line %s : header closed without a title' % [line_number])
					node['header']['title'] = 'Anonymous Node %s' % [line_number]
					continue
				
			else:
				var split := line.split(':', 1)
				if split.size() < 2:
					print('[ERROR] Line %s : invalid header line : %s' % [line_number, line])
					continue

				var key := split[0]
				var value := split[1].strip_edges()

				# TODO If key == 'tags', split value ?

				node.header[key] = value

		else:
			if line == '===':
				header = true
				_add_node(node)
				node = YarnNode.new()

			else:
				var indent = _indent_of(line)
				# print(indent, ' ', line)
				
				while indent < indents[-1]:
					blocks.pop_back()
					indents.pop_back()
				
				if indent > indents[-1]:
					if blocks[-1].get_statement(-1) is YarnBlock:
						blocks.append(blocks[-1].get_statement(-1))
					else:
						print('[ERROR] Line  %s : nested statement outside of a block: %s' % [line_number, line])
				
				var statement = _new_statement(line.strip_edges())
				if statement:
					blocks[-1].append(statement)


func _new_statement(line: String) -> YarnStatement:
	# choice
	if (line.begins_with('[[') and line.ends_with(']]')):
		line = line.substr(2, line.length() - 4).strip_edges()

		var pipe = line.find('|')
		
		if pipe >= 0:
			var text = line.substr(0, pipe).strip_edges()
			var node_name = line.substr(pipe + 1).strip_edges()
			return YarnOption.new(text, node_name)
		else:
			return YarnJump.new(line)
			
	# commands
	elif (line.begins_with('<<') and line.ends_with('>>')):
		line = line.substr(2, line.length() - 4).strip_edges()
		return YarnCommand.new(line)
	
	# TODO shortcut options
	elif line.begins_with('->'):
		line = line.substr(2).strip_edges()
		return YarnShortcutOption.new(line)
		
	# TODO set values
	# TODO conditionals
	# TODO expressions
	else:
		# dialogue line
		var character_name : String = ''
		var colon = line.find(': ')
		if colon >= 0:
			character_name = line.substr(0, colon)
			line = line.substr(colon + ': '.length())
		return YarnDialogue.new(character_name, line)


func _indent_of(line: String) -> int:
	var indent : int = 0
	while indent < line.length() and (line[indent] == ' ' || line[indent] == '\t'):
		indent += 1
	return indent


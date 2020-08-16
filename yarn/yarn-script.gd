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
		# read a line
		var line := file.get_line()
		line_number += 1
		
		# Skip empty lines
		if line.strip_edges().empty():
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
					print('[ERROR] Line %s : invalid header line: %s' % [line_number, line])
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
				var action = _new_action(line)
				if action:
					node.body.append(action)


func _new_action(line: String) -> YarnAction:
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


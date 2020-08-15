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

var yarn = {}

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
		
		print('TREE', scene.get_tree())
		lock()
		yield(scene.get_tree().create_timer(time_sec), "timeout")
		print('AFTER %s' % [time_sec])
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
	
# called for each node name
func yarn_starts_unraveling(to: String):
	pass

# called for each node name (after)
func yarn_stops_unraveling(to: String):
	pass

# START SPINNING YOUR YARN
#
func spin_yarn(file):
	yarn = load_yarn(file)
	# Find the starting node...
	node = yarn['threads'][yarn['start']]
	# Load any scene-specific settings
	# (Not part of official Yarn standard)
	if 'settings' in yarn['threads']:
		var settings = yarn['threads']['settings']
		for fibre in settings['dialogue']:
			var line = fibre['text']
			var split = line.split('=')
			var setting = split[0].strip_edges(true, true)
			var value = split[1].strip_edges(true, true)
			story_setting(setting, value)
	# First node unravel...
	# yarn_unravel(start_thread)

# Internally create a new node (during loading)
# TODO Do a class version of this ?
func _new_node() -> Dictionary:
	return {
		'header': {},
		'dialogue': []
	}

# Internally create a new fibre (during loading)
func _new_dialogue_line(line: String):
	# choice
	if (line.begins_with('[[') and line.ends_with(']]')):
		line = line.substr(2, line.length() - 4).strip_edges()

		var pipe = line.find('|')
		
		if pipe >= 0:
			var text = line.substr(0, pipe).strip_edges()
			var node_name = line.substr(pipe + 1).strip_edges()
			
			return {
				'kind': 'choice',
				'text': text,
				'node_name': node_name
			}
		else:
			return {
				'kind': 'jump',
				'node_name': line
			}
			
	# commands
	elif (line.begins_with('<<') and line.ends_with('>>')):
		line = line.substr(2, line.length() - 4).strip_edges()
		return {
			'kind': 'command',
			'text': line
		}
	
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
		return {
			'kind': 'line_of_dialogue',
			'character': character_name,
			'line': line
		}

# Create Yarn data structure from file (must be *.yarn.txt Yarn format)
func load_yarn(path):
	var yarn = {}
	yarn['threads'] = {}
	yarn['start'] = false
	yarn['file'] = path
	
	var file := File.new()
	file.open(path, file.READ)
	
	if file.is_open():
		# yarn reading flags
		var header := true
		var node := _new_node()
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
					if not node['header'].has('title'):
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

					node['header'][key] = value

			else:
				if line == '===':
					header = true
					yarn['threads'][node['header']['title']] = node
					if not yarn['start']:
						yarn['start'] = node['header']['title']
					node = _new_node()

				else:
					var dialogue_line = _new_dialogue_line(line)
					if dialogue_line:
						node['dialogue'].append(dialogue_line)
	else:
		print('ERROR: Yarn file missing: ', filename)
	return yarn

# Main logic for node handling
#
func yarn_unravel(to):
	node = yarn['threads'][to]
	next_step = 0

func _foo(to):
	yarn_starts_unraveling(to)
	if to in yarn['threads']:
		var node = yarn['threads'][to]
		for line in node['dialogue']:
			match line['kind']:
				'line_of_dialogue':
					var character: String = line['character']
					var text : String = yarn_text_variables(line['line'])
					# TODO Use character name as well !
					say(character, text)
				'choice':
					var text : String = yarn_text_variables(line['text'])
					var node_name : String = line['node_name']
					choice(text, node_name)
				'jump':
					var node_name : String = line['node_name']
					jump(node_name)
				'command':
					var text = line['text']
					command(text)
	else:
		print('WARNING: Missing Yarn node: ', to, ' in file ',yarn['file'])
	yarn_stops_unraveling(to)

func can_step() -> bool:
	return not locked and node != null and next_step < node['dialogue'].size()

func step() -> void:
	if not can_step(): return
	var line = node['dialogue'][next_step]
	next_step += 1
	match line['kind']:
		'line_of_dialogue':
			var character: String = line['character']
			var text : String = yarn_text_variables(line['line'])
			# TODO Use character name as well !
			say(character, text)
		'choice':
			var text : String = yarn_text_variables(line['text'])
			var node_name : String = line['node_name']
			choice(text, node_name)
		'jump':
			var node_name : String = line['node_name']
			jump(node_name)
		'command':
			var text = line['text']
			command(text)
	
func lock():
	locked = true

func unlock():
	locked = false


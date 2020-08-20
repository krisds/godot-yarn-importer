extends YarnStatement

class_name YarnBlock

var _statements : Array = []

func _init():
	pass

func append(action : YarnStatement) -> void:
	_statements.append(action)

func get_statement(index: int) -> YarnStatement:
	return _statements[index]

func statement_count() -> int:
	return _statements.size()

func empty() -> bool:
	return _statements.empty()

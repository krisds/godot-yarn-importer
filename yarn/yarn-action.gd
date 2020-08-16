class_name YarnAction

enum Type {
	DIALOGUE,
	OPTION,
	JUMP,
	COMMAND
}

# One of YarnAction.Type
var kind : int

func _init(_kind : int):
	kind = _kind

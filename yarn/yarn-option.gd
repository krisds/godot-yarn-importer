extends YarnAction

class_name YarnOption

var text : String
var to_node_name : String

func _init(_text: String, _to_node_name: String).(YarnAction.Type.OPTION):
	text = _text
	to_node_name = _to_node_name

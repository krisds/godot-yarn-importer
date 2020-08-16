extends YarnAction

class_name YarnDialogue

var character : String
var text : String

func _init(_character: String, _text: String).(YarnAction.Type.DIALOGUE):
	character = _character
	text = _text

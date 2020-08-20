class_name YarnNode

var header : Dictionary = {}
var body   : YarnBlock  = null

func _init():
	body = YarnBlock.new()

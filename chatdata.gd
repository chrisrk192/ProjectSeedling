class_name ChatData
extends Resource

var model :String
var prompt: String
var stream: bool

func to_dict() -> Dictionary:
	return {
		"model": model,
		"prompt": prompt,
		"stream": stream
	}

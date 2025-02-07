class_name ChatData
extends Resource

var model :String
var system: String
var prompt: String
var stream: bool

func to_dict() -> Dictionary:
	return {
		"model": model,
		"system": system,
		"prompt": prompt,
		"stream": stream
	}

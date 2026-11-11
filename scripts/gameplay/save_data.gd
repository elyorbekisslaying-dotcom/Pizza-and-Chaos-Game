class_name PizzaSaveData
extends RefCounted

const SAVE_PATH := "user://pizza_chaos.cfg"

static func load_stats() -> Dictionary:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return {"best_score": 0}
	return {"best_score": int(config.get_value("records", "best_score", 0))}

static func save_stats(stats: Dictionary) -> void:
	var config := ConfigFile.new()
	config.set_value("records", "best_score", int(stats.get("best_score", 0)))
	config.save(SAVE_PATH)

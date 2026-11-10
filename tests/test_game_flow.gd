extends SceneTree

const MainScene = preload("res://scenes/main.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := MainScene.instantiate()
	root.add_child(main)
	await process_frame
	var stack = main.get_node("StackGame")
	stack.start_round()
	var failures: Array[String] = []
	_check("first ingredient is dough", stack.active_ingredient_id == "dough", failures)
	for i in range(3):
		stack._land_active()
	_check("classic sequence reaches pepperoni", stack.active_ingredient_id == "pepperoni", failures)
	stack._land_active()
	_check("completion advances to mushroom pizza", stack.recipe_index == 1, failures)
	_check("new recipe starts at dough", stack.active_ingredient_id == "dough" and stack.ingredient_index == 0, failures)
	_check("four landed layers counted independently", stack.offsets.size() == 4 and stack.recipes_completed == 1, failures)
	if failures.is_empty():
		print("PASS: 5 game-flow scenarios")
		quit(0)
		return
	for failure in failures:
		push_error("FAIL: " + failure)
	quit(1)

func _check(label: String, passed: bool, failures: Array[String]) -> void:
	if not passed:
		failures.append(label)

extends SceneTree

const MainScene = preload("res://scenes/main.tscn")
const StackGame = preload("res://scripts/gameplay/stack_game.gd")
const Balance = preload("res://data/game_balance.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main := MainScene.instantiate()
	root.add_child(main)
	await process_frame
	var game = main.get_node("StackGame")
	var failures: Array[String] = []
	game.start_round()
	await process_frame
	_check("round creates exactly one permanent dough base", game.base != null and game.base is StaticBody2D, failures)
	_check("base remains anchored at the starting position", game.base.position.is_equal_approx(Vector2(0.0, StackGame.BASE_Y)), failures)
	_check("first moving piece is cheese, not another dough base", game.active.ingredient_id == "mozzarella", failures)
	_check("active topping has a collision shape", game.active.get_node_or_null("CollisionShape2D") != null, failures)
	_check("Space input is mapped", _has_key("drop_ingredient", KEY_SPACE), failures)
	_check("drop event accepts left click", StackGame.should_drop_on_event(_mouse_event(MOUSE_BUTTON_LEFT)), failures)
	_check("drop event rejects right click", not StackGame.should_drop_on_event(_mouse_event(MOUSE_BUTTON_RIGHT)), failures)
	for i in range(4):
		game.active.position.x = 0.0
		game._drop_active()
		await _wait_until_landed(game)
		await process_frame
		_check("topping lands through physics on layer %d" % (i + 1), game.landed.size() == i + 1, failures)
		_check("landed topping freezes to keep stack predictable", game.landed[i].freeze, failures)
		_check("dough base does not move during stacking", game.base.position.is_equal_approx(Vector2(0.0, StackGame.BASE_Y)), failures)
	_check("score increases once per placed topping", game.score == 4, failures)
	_check("automatic order includes tomato, pepperoni, and mushrooms", game.active.ingredient_id == "olives", failures)
	_check("movement speed increases with score", game.move_speed > Balance.START_SPEED, failures)
	await create_timer(0.55).timeout
	_check("camera follows stack upward", game.camera.position.y < 0.0, failures)
	_check("best score is shown during play", int(game.stats.get("best_score", -1)) >= 0, failures)
	game.start_round()
	await process_frame
	_check("restart clears layers and score", game.landed.is_empty() and game.score == 0, failures)
	_check("restart recreates one base and resets ingredient order", game.base != null and game.active.ingredient_id == "mozzarella", failures)
	game.active.position.x = 0.0
	game._drop_active()
	await _wait_until_landed(game)
	game.active.position.x = 100.0
	game._drop_active()
	await _wait_until_finished(game)
	_check("unsafe overhang ends the round", not game.game_active, failures)
	_check("final score includes only safely placed toppings", game.score >= 1 and game.score <= 2, failures)
	_check("collapse releases the placed stack", game.landed[0].freeze == false, failures)
	if failures.is_empty():
		print("PASS: gameplay, collision, scoring, camera, collapse, and restart scenarios")
		quit(0)
		return
	for failure in failures:
		push_error("FAIL: " + failure)
	quit(1)

func _wait_until_landed(game: Node) -> void:
	for frame in range(240):
		if not game.falling:
			return
		await physics_frame

func _wait_until_finished(game: Node) -> void:
	for frame in range(240):
		if not game.game_active:
			return
		await physics_frame

func _mouse_event(button: MouseButton) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	return event

func _has_key(action: StringName, keycode: Key) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and (event.physical_keycode == keycode or event.keycode == keycode):
			return true
	return false

func _check(label: String, passed: bool, failures: Array[String]) -> void:
	if not passed:
		failures.append(label)

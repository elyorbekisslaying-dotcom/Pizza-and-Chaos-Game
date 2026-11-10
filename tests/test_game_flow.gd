extends SceneTree

const MainScene = preload("res://scenes/main.tscn")
const StackLogic = preload("res://scripts/gameplay/stack_game.gd")
const StackBending = preload("res://scripts/physics/tower_bending.gd")
const Balance = preload("res://data/game_balance.gd")

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
	_check("base preview starts centered", is_zero_approx(stack.active_node.position.x), failures)
	_check("mouse maps to centerline-relative offset", is_equal_approx(StackLogic.mouse_world_x_to_offset(74.0, 24.0), 50.0), failures)
	_check("mouse offset respects play bounds", is_equal_approx(StackLogic.mouse_world_x_to_offset(800.0, 0.0), 220.0), failures)
	_check("A/left movement direction is negative", StackLogic.movement_direction(true, false) == -1.0, failures)
	_check("D/right movement direction is positive", StackLogic.movement_direction(false, true) == 1.0, failures)
	_check("opposed movement keys cancel", StackLogic.movement_direction(true, true) == 0.0, failures)
	_check("A and left arrow are mapped", _has_key("move_left", KEY_A) and _has_key("move_left", KEY_LEFT), failures)
	_check("D and right arrow are mapped", _has_key("move_right", KEY_D) and _has_key("move_right", KEY_RIGHT), failures)
	_check("Space is mapped to drop", _has_key("drop_ingredient", KEY_SPACE), failures)
	var mouse_drop := InputEventMouseButton.new()
	mouse_drop.button_index = MOUSE_BUTTON_LEFT
	mouse_drop.pressed = true
	var right_click := InputEventMouseButton.new()
	right_click.button_index = MOUSE_BUTTON_RIGHT
	right_click.pressed = true
	_check("left click drops", StackLogic.should_drop_on_event(mouse_drop), failures)
	_check("right click does not drop", not StackLogic.should_drop_on_event(right_click), failures)
	var space_drop := InputEventKey.new()
	space_drop.physical_keycode = KEY_SPACE
	space_drop.pressed = true
	_check("Space drop event is recognized", StackLogic.should_drop_on_event(space_drop), failures)
	var camera_start_y: float = stack.camera.position.y
	stack._drop_active()
	var expected_start_y := StackLogic.calculate_fall_start_y(camera_start_y, stack.get_viewport_rect().size.y, Balance.FALL_TOP_INSET)
	_check("drop immediately places ingredient at its computed start", is_equal_approx(stack.active_node.position.y, expected_start_y), failures)
	_check("fall begins clearly above the landing target", stack.last_fall_start.y < stack.last_fall_target.y - 200.0, failures)
	_check("fall keeps x fixed for a vertical drop", is_equal_approx(stack.last_fall_start.x, stack.last_fall_target.x), failures)
	var first_drop: Tween = stack.active_drop_tween
	await first_drop.finished
	await process_frame
	_check("landed base dough remains exactly at x=0", is_zero_approx(stack.ingredient_nodes[0].position.x), failures)
	_check("dough base is stored with zero offset", is_zero_approx(stack.offsets[0]), failures)
	_check("classic sequence reaches tomato sauce", stack.active_ingredient_id == "sauce", failures)
	await _drop_and_wait(stack, 20.0)
	var base_x_after_sauce: float = stack.ingredient_nodes[0].position.x
	var sauce_x_after_sauce: float = stack.ingredient_nodes[1].position.x
	_check("second layer lands at its preview x", is_equal_approx(sauce_x_after_sauce, stack.last_fall_target.x), failures)
	_check("placing sauce leaves the base anchored", is_zero_approx(base_x_after_sauce), failures)
	_check("sauce offset is retained", is_equal_approx(stack.ingredient_nodes[1].position.x - StackBending.centerline_curve(stack.offsets)[1], 20.0), failures)
	await _drop_and_wait(stack, -10.0)
	var prior_positions: Array[float] = []
	for node in stack.ingredient_nodes:
		prior_positions.append(node.position.x)
	_check("classic sequence reaches pepperoni after mozzarella", stack.active_ingredient_id == "pepperoni", failures)
	await _drop_and_wait(stack, 5.0)
	var old_layers_unchanged := true
	for i in range(prior_positions.size()):
		old_layers_unchanged = old_layers_unchanged and is_equal_approx(prior_positions[i], stack.ingredient_nodes[i].position.x)
	_check("new placement does not shift landed ingredients", old_layers_unchanged, failures)
	_check("upper centerline uses accumulated lower moments", stack.ingredient_nodes[3].position.x - stack.offsets[3] > 0.0, failures)
	_check("recipe completion advances to mushroom pizza", stack.recipe_index == 1, failures)
	_check("new recipe starts on dough despite four tower layers", stack.active_ingredient_id == "dough" and stack.ingredient_index == 0, failures)
	_check("four physical drops complete one recipe", stack.offsets.size() == 4 and stack.recipes_completed == 1, failures)
	var camera_target_y := -float(stack.offsets.size()) * Balance.LAYER_SPACING - 165.0
	var old_camera_y: float = stack.camera.position.y
	stack._process(0.3)
	_check("camera eases toward the growing tower", absf(stack.camera.position.y - camera_target_y) < absf(old_camera_y - camera_target_y), failures)
	var active_world_position: Vector2 = stack.active_node.position
	stack._process(0.2)
	_check("camera motion leaves the active world position predictable", stack.active_node.position.is_equal_approx(active_world_position), failures)
	if failures.is_empty():
		print("PASS: 30 gameplay, control, falling, camera, and recipe scenarios")
		quit(0)
		return
	for failure in failures:
		push_error("FAIL: " + failure)
	quit(1)

func _drop_and_wait(stack, offset: float) -> void:
	stack.active_offset = offset
	stack._update_active_position()
	stack._drop_active()
	var drop: Tween = stack.active_drop_tween
	await drop.finished
	await process_frame

func _has_key(action: StringName, keycode: Key) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and (event.physical_keycode == keycode or event.keycode == keycode):
			return true
	return false

func _check(label: String, passed: bool, failures: Array[String]) -> void:
	if not passed:
		failures.append(label)

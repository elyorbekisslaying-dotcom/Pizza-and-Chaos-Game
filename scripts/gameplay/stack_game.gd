extends Node2D

signal stats_changed(stats: Dictionary)
signal round_finished(stats: Dictionary)
signal placement_landed(position: Vector2)

const Bending = preload("res://scripts/physics/tower_bending.gd")
const Recipes = preload("res://data/recipes.gd")
const Balance = preload("res://data/game_balance.gd")
const SaveData = preload("res://scripts/gameplay/save_data.gd")
const Burst = preload("res://scripts/gameplay/landing_burst.gd")
const IngredientScene = preload("res://scenes/ingredient.tscn")
const LAYER_SPACING := Balance.LAYER_SPACING
const HORIZONTAL_LIMIT := Balance.HORIZONTAL_LIMIT
const DROP_SPEED := Balance.DROP_SPEED

@onready var camera: Camera2D = $Camera2D
@onready var tower: Node2D = $Tower

var offsets: Array[float] = []
var ingredient_nodes: Array[IngredientView] = []
var active_node: IngredientView
var active_offset := 0.0
var active_ingredient_id := "dough"
var recipe_index := 0
var ingredient_index := 0
var score := 0
var recipes_completed := 0
var falling := false
var game_active := false
var current_stats: Dictionary = {}
var best_stats: Dictionary = {}
var reflow_tween: Tween
var ambient_time := 0.0

func _ready() -> void:
	best_stats = SaveData.load_stats()
	queue_redraw()
	set_process(true)

func start_round() -> void:
	_clear_tower()
	offsets.clear()
	ingredient_nodes.clear()
	active_node = null
	recipe_index = 0
	ingredient_index = 0
	score = 0
	recipes_completed = 0
	falling = false
	game_active = true
	camera.position = Vector2(0, 150)
	camera.offset = Vector2.ZERO
	tower.position = Vector2.ZERO
	tower.rotation = 0.0
	current_stats = {"score": 0, "height": 0, "recipes": 0, "stability": 1.0, "recipe": "", "ingredient": ""}
	set_process(true)
	_prepare_active()
	_emit_stats()

func show_menu_background() -> void:
	game_active = false
	falling = false
	_clear_tower()
	offsets.clear()
	ingredient_nodes.clear()
	active_node = null
	camera.position = Vector2(0, 150)
	camera.offset = Vector2.ZERO
	tower.position = Vector2.ZERO
	tower.rotation = 0.0
	queue_redraw()

func _clear_tower() -> void:
	for child in tower.get_children():
		child.queue_free()

func _process(delta: float) -> void:
	ambient_time += delta
	if game_active:
		var desired_camera_y := -float(offsets.size()) * LAYER_SPACING - 165.0
		camera.position.y = lerpf(camera.position.y, desired_camera_y, 1.0 - exp(-delta * 4.0))
		if active_node != null and not falling:
			if Input.is_action_pressed("move_left"):
				active_offset -= (245.0 + float(offsets.size()) * 4.0) * delta
			if Input.is_action_pressed("move_right"):
				active_offset += (245.0 + float(offsets.size()) * 4.0) * delta
			active_offset = clampf(active_offset, -HORIZONTAL_LIMIT, HORIZONTAL_LIMIT)
			_update_active_position()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not game_active or falling:
		return
	if event is InputEventMouseMotion:
		var center := Bending.top_displacement(offsets)
		active_offset = clampf(get_global_mouse_position().x - center, -HORIZONTAL_LIMIT, HORIZONTAL_LIMIT)
		_update_active_position()
		return
	if event.is_action_pressed("drop_ingredient") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		_drop_active()
		get_viewport().set_input_as_handled()

func _draw() -> void:
	var cy := camera.position.y if camera != null else 0.0
	var cx := camera.position.x if camera != null else 0.0
	draw_rect(Rect2(cx - 680, cy - 900, 1360, 1800), Color("f7d9a8"))
	for i in range(12):
		var y := cy - 840.0 + float(i) * 150.0
		draw_line(Vector2(cx - 680, y), Vector2(cx + 680, y), Color(0.86, 0.68, 0.49, 0.42), 2.0)
	for i in range(7):
		var x := cx - 560.0 + float(i) * 185.0
		draw_line(Vector2(x, cy - 900), Vector2(x, cy + 900), Color(0.89, 0.73, 0.54, 0.33), 1.0)
	# Kitchen wall accents stay decorative and do not feed back into the stack math.
	for i in range(9):
		var x := cx - 540.0 + float(i) * 135.0
		var y := cy + 330.0 + sin(float(i) * 2.0 + ambient_time * 0.35) * 22.0
		draw_circle(Vector2(x, y), 5.0, Color(0.80, 0.35, 0.27, 0.38))
	for i in range(5):
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := cx + side * (390.0 + float(i % 3) * 62.0)
		var y := cy - 300.0 + float(i) * 158.0 + sin(ambient_time * 0.6 + float(i)) * 8.0
		draw_circle(Vector2(x, y), 13.0, Color(0.75, 0.25, 0.21, 0.18))
		draw_circle(Vector2(x - 3.5, y - 4.0), 2.0, Color(1.0, 0.8, 0.55, 0.33))

func _drop_active() -> void:
	if active_node == null:
		return
	falling = true
	var top_bend := Bending.top_displacement(offsets)
	var x_target := top_bend + active_offset
	var y_target := -float(offsets.size()) * LAYER_SPACING
	var y_start := camera.position.y - 330.0
	var duration := maxf(0.38, absf(y_start - y_target) / DROP_SPEED)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(active_node, "position", Vector2(x_target, y_target), duration)
	tween.finished.connect(_land_active)

func _land_active() -> void:
	if not game_active or active_node == null:
		return
	var landed := active_node
	active_node = null
	landed.preview = false
	landed.queue_redraw()
	var local_offset := active_offset
	offsets.append(local_offset)
	ingredient_nodes.append(landed)
	var layer_index := offsets.size() - 1
	var curve := Bending.centerline_curve(offsets)
	var target := Vector2(curve[layer_index] + local_offset, -float(layer_index) * LAYER_SPACING)
	landed.position = Vector2(Bending.top_displacement(offsets) + local_offset, target.y)
	if reflow_tween and reflow_tween.is_running():
		reflow_tween.kill()
	reflow_tween = create_tween().set_parallel(true)
	for i in range(ingredient_nodes.size()):
		var node := ingredient_nodes[i]
		var destination := Vector2(curve[i] + offsets[i], -float(i) * LAYER_SPACING)
		reflow_tween.tween_property(node, "position", destination, 0.42).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var precision_bonus := maxi(0, 100 - int(absf(local_offset) * 0.72))
	score += 50 + precision_bonus
	current_stats["score"] = score
	current_stats["height"] = offsets.size()
	current_stats["stability"] = Bending.stability(offsets)
	placement_landed.emit(target)
	var burst := Burst.new()
	add_child(burst)
	burst.play(target)
	var camera_tween := create_tween()
	camera_tween.tween_property(camera, "offset", Vector2(0, -4), 0.06)
	camera_tween.tween_property(camera, "offset", Vector2.ZERO, 0.16)
	_advance_recipe()
	_emit_stats()
	if Bending.is_unstable(offsets):
		_finish_round()
	else:
		_prepare_active()

func _advance_recipe() -> void:
	var recipe: Dictionary = Recipes.RECIPES[recipe_index]
	ingredient_index += 1
	if ingredient_index >= recipe["ingredients"].size():
		recipes_completed += 1
		score += 500
		ingredient_index = 0
		recipe_index = (recipe_index + 1) % Recipes.RECIPES.size()
	current_stats["recipes"] = recipes_completed
	current_stats["score"] = score
	current_stats["recipe"] = Recipes.RECIPES[recipe_index]["name"]

func _prepare_active() -> void:
	if not game_active:
		return
	var recipe: Dictionary = Recipes.RECIPES[recipe_index]
	var recipe_ingredients: Array = recipe["ingredients"]
	if ingredient_index < 0 or ingredient_index >= recipe_ingredients.size():
		ingredient_index = 0
	active_ingredient_id = recipe_ingredients[ingredient_index]
	active_offset = 0.0
	active_node = IngredientScene.instantiate() as IngredientView
	active_node.setup(active_ingredient_id, true)
	tower.add_child(active_node)
	_update_active_position()
	current_stats["recipe"] = recipe["name"]
	current_stats["ingredient"] = Recipes.ingredient_data(active_ingredient_id)["label"]
	current_stats["next_ingredient"] = _next_ingredient_label()
	_emit_stats()

func _next_ingredient_label() -> String:
	var recipe: Dictionary = Recipes.RECIPES[recipe_index]
	var next_index := ingredient_index + 1
	if next_index >= recipe["ingredients"].size():
		var next_recipe: Dictionary = Recipes.RECIPES[(recipe_index + 1) % Recipes.RECIPES.size()]
		return Recipes.ingredient_data(next_recipe["ingredients"][0])["label"]
	return Recipes.ingredient_data(recipe["ingredients"][next_index])["label"]

func _update_active_position() -> void:
	if active_node == null:
		return
	var center := Bending.top_displacement(offsets)
	var preview_y := -float(offsets.size()) * LAYER_SPACING
	active_node.position = Vector2(center + active_offset, preview_y)

func _finish_round() -> void:
	game_active = false
	current_stats["score"] = score
	current_stats["height"] = offsets.size()
	current_stats["recipes"] = recipes_completed
	current_stats["stability"] = Bending.stability(offsets)
	var record_broken := score > int(best_stats.get("best_score", 0)) or offsets.size() > int(best_stats.get("best_height", 0))
	best_stats["best_score"] = maxi(int(best_stats.get("best_score", 0)), score)
	best_stats["best_height"] = maxi(int(best_stats.get("best_height", 0)), offsets.size())
	best_stats["best_recipes"] = maxi(int(best_stats.get("best_recipes", 0)), recipes_completed)
	SaveData.save_stats(best_stats)
	current_stats["best_score"] = best_stats["best_score"]
	current_stats["record_broken"] = record_broken
	current_stats["feedback"] = _performance_feedback()
	var collapse_direction := signf(Bending.signed_moment(offsets))
	if is_zero_approx(collapse_direction):
		collapse_direction = 1.0
	var collapse := create_tween()
	collapse.set_parallel(true)
	collapse.tween_property(tower, "rotation", deg_to_rad(collapse_direction * 13.0), 0.52).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	collapse.tween_property(tower, "position", Vector2(collapse_direction * 32.0, 72.0), 0.58).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var shake := create_tween()
	shake.tween_property(camera, "offset", Vector2(-9.0, 5.0), 0.045)
	shake.tween_property(camera, "offset", Vector2(8.0, -4.0), 0.055)
	shake.tween_property(camera, "offset", Vector2(-4.0, 2.0), 0.07)
	shake.tween_property(camera, "offset", Vector2.ZERO, 0.1)
	round_finished.emit(current_stats.duplicate(true))

func _performance_feedback() -> String:
	if recipes_completed >= 4:
		return "Pizza legend! You tamed the tower."
	if recipes_completed >= 2:
		return "A deliciously balanced run."
	if offsets.size() >= 8:
		return "Nearly a pizza skyscraper!"
	return "Every great chef learns to balance."

func _emit_stats() -> void:
	if current_stats.is_empty():
		return
	current_stats["score"] = score
	current_stats["height"] = offsets.size()
	current_stats["recipes"] = recipes_completed
	current_stats["stability"] = Bending.stability(offsets)
	current_stats["best_score"] = int(best_stats.get("best_score", 0))
	if recipe_index >= 0 and recipe_index < Recipes.RECIPES.size():
		current_stats["recipe"] = Recipes.RECIPES[recipe_index]["name"]
	stats_changed.emit(current_stats.duplicate(true))

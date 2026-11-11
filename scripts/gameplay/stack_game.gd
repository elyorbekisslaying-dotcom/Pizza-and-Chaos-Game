extends Node2D

signal stats_changed(stats: Dictionary)
signal round_finished(stats: Dictionary)

const Balance = preload("res://data/game_balance.gd")
const StackLogic = preload("res://scripts/physics/stack_balance.gd")
const SaveData = preload("res://scripts/gameplay/save_data.gd")
const IngredientScene = preload("res://scenes/ingredient.tscn")
const SEQUENCE: Array[String] = ["mozzarella", "tomato", "pepperoni", "mushrooms", "olives"]
const BASE_Y := 255.0
const CAMERA_START_Y := 0.0

@onready var camera: Camera2D = $Camera2D
@onready var tower: Node2D = $Tower

var landed: Array[IngredientView] = []
var base: StaticBody2D
var active: IngredientView
var score := 0
var game_active := false
var falling := false
var settle_time := 0.0
var move_direction := 1.0
var move_speed := 210.0
var ambient_time := 0.0
var best_score := 0
var stats: Dictionary = {}

static func should_drop_on_event(event: InputEvent) -> bool:
	return event.is_action_pressed("drop_ingredient") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)

func _ready() -> void:
	best_score = int(SaveData.load_stats().get("best_score", 0))
	set_physics_process(true)
	queue_redraw()

func start_round() -> void:
	_clear_stack()
	score = 0
	game_active = true
	falling = false
	settle_time = 0.0
	move_direction = 1.0
	move_speed = Balance.START_SPEED
	camera.position = Vector2(0, CAMERA_START_Y)
	stats = {"score": 0, "height": 0, "best_score": best_score, "ingredient": "Mozzarella", "ingredient_id": "mozzarella"}
	_create_base()
	_spawn_active()
	_emit_stats()

func show_menu_background() -> void:
	game_active = false
	falling = false
	_clear_stack()
	camera.position = Vector2(0, CAMERA_START_Y)
	queue_redraw()

func _clear_stack() -> void:
	for child in tower.get_children():
		child.queue_free()
	landed.clear()
	base = null
	active = null

func _create_base() -> void:
	base = StaticBody2D.new()
	base.name = "PermanentDoughBase"
	base.position = Vector2(0, BASE_Y)
	tower.add_child(base)
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(Balance.INGREDIENT_WIDTH, Balance.INGREDIENT_HEIGHT)
	shape.shape = rectangle
	base.add_child(shape)
	var art := IngredientScene.instantiate() as IngredientView
	art.preview_only = true
	art.setup("dough", false)
	art.position = Vector2.ZERO
	base.add_child(art)

func _physics_process(delta: float) -> void:
	ambient_time += delta
	if not game_active:
		queue_redraw()
		return
	if active != null and not falling:
		var input_direction := float(Input.is_action_pressed("move_right")) - float(Input.is_action_pressed("move_left"))
		if not is_zero_approx(input_direction):
			active.position.x += input_direction * move_speed * delta
		else:
			active.position.x += move_direction * move_speed * delta
		if absf(active.position.x) >= Balance.HORIZONTAL_LIMIT:
			active.position.x = clampf(active.position.x, -Balance.HORIZONTAL_LIMIT, Balance.HORIZONTAL_LIMIT)
			move_direction *= -1.0
		active.position.y = _spawn_height()
	if falling and active != null:
		if active.get_contact_count() > 0:
			active.lock_rotation = false
		if active.sleeping or (active.get_contact_count() > 0 and active.linear_velocity.length() < 18.0 and absf(active.angular_velocity) < 0.18):
			settle_time += delta
		else:
			settle_time = 0.0
		if settle_time >= 0.28:
			_land_active()
		elif active.global_position.y > BASE_Y + 420.0:
			_finish_round()
	var target_y := minf(CAMERA_START_Y, BASE_Y - 210.0 - float(landed.size()) * Balance.CAMERA_STEP)
	camera.position.y = lerpf(camera.position.y, target_y, 1.0 - exp(-delta * 3.5))
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not game_active or falling or active == null:
		return
	if event is InputEventMouseMotion:
		var mouse_x := get_global_mouse_position().x
		active.position.x = clampf(mouse_x, -Balance.HORIZONTAL_LIMIT, Balance.HORIZONTAL_LIMIT)
	if should_drop_on_event(event):
		_drop_active()
		get_viewport().set_input_as_handled()

func _drop_active() -> void:
	if active == null or falling:
		return
	falling = true
	settle_time = 0.0
	active.preview = false
	active.queue_redraw()
	active.position.y = _spawn_height()
	active.freeze = false
	active.lock_rotation = true
	active.gravity_scale = 1.0
	active.collision_layer = 1
	active.collision_mask = 1
	active.linear_velocity = Vector2.ZERO
	active.angular_velocity = 0.0
	active.sleeping = false

func _land_active() -> void:
	if active == null or not game_active:
		return
	var landed_piece := active
	landed_piece.linear_velocity = Vector2.ZERO
	landed_piece.angular_velocity = 0.0
	landed_piece.freeze = true
	landed_piece.lock_rotation = false
	landed_piece.preview = false
	landed_piece.queue_redraw()
	landed.append(landed_piece)
	active = null
	falling = false
	settle_time = 0.0
	score += 1
	move_speed = minf(Balance.MAX_SPEED, Balance.START_SPEED + float(score) * Balance.SPEED_PER_SCORE)
	stats["score"] = score
	stats["height"] = score
	stats["best_score"] = best_score
	_emit_stats()
	if _is_stack_unbalanced():
		_collapse_stack()
		return
	_spawn_active()

func _spawn_active() -> void:
	if not game_active:
		return
	active = IngredientScene.instantiate() as IngredientView
	active.setup(SEQUENCE[score % SEQUENCE.size()], true)
	active.position = Vector2(-Balance.HORIZONTAL_LIMIT, _spawn_height())
	active.freeze = true
	active.lock_rotation = true
	active.gravity_scale = 0.0
	active.collision_layer = 0
	active.collision_mask = 0
	tower.add_child(active)
	move_direction = 1.0
	stats["ingredient"] = active.ingredient_label()
	stats["ingredient_id"] = active.ingredient_id
	_emit_stats()

func _spawn_height() -> float:
	if landed.is_empty():
		return BASE_Y - Balance.DROP_CLEARANCE
	var top := landed.back()
	return top.position.y - Balance.DROP_CLEARANCE

func _is_stack_unbalanced() -> bool:
	var centers: Array[float] = [base.position.x]
	for piece in landed:
		centers.append(piece.position.x)
	return StackLogic.is_unstable(centers)

func _collapse_stack() -> void:
	falling = false
	var direction := signf(landed.back().position.x - base.position.x)
	if is_zero_approx(direction):
		direction = 1.0
	for i in range(landed.size()):
		var piece := landed[i]
		piece.freeze = false
		piece.lock_rotation = false
		piece.gravity_scale = 1.2
		piece.angular_velocity = direction * (0.35 + i * 0.045)
		piece.apply_central_impulse(Vector2(direction * (55.0 + i * 7.0), -20.0))
	_finish_round()

func _finish_round() -> void:
	if not game_active:
		return
	game_active = false
	var record_broken := score > best_score
	best_score = maxi(best_score, score)
	SaveData.save_stats({"best_score": best_score})
	stats["score"] = score
	stats["height"] = score
	stats["best_score"] = best_score
	stats["record_broken"] = record_broken
	stats["feedback"] = "You stacked %d delicious layers!" % score
	round_finished.emit(stats.duplicate(true))

func _emit_stats() -> void:
	stats_changed.emit(stats.duplicate(true))

func _draw() -> void:
	var cy := camera.position.y if camera != null else CAMERA_START_Y
	var cx := camera.position.x if camera != null else 0.0
	draw_rect(Rect2(cx - 680, cy - 900, 1360, 1800), Color("f7d9a8"))
	for i in range(12):
		var y := cy - 840.0 + float(i) * 150.0
		draw_line(Vector2(cx - 680, y), Vector2(cx + 680, y), Color(0.86, 0.68, 0.49, 0.42), 2.0)
	for i in range(7):
		var x := cx - 560.0 + float(i) * 185.0
		draw_line(Vector2(x, cy - 900), Vector2(x, cy + 900), Color(0.89, 0.73, 0.54, 0.33), 1.0)

class_name IngredientView
extends Node2D

const Balance = preload("res://data/game_balance.gd")
const W := Balance.INGREDIENT_WIDTH
const H := Balance.INGREDIENT_HEIGHT

var ingredient_id := "dough"
var preview := false

func setup(id: String, is_preview: bool = false) -> void:
	ingredient_id = id
	preview = is_preview
	queue_redraw()

func _draw() -> void:
	var alpha := 0.67 if preview else 1.0
	_draw_ellipse(Vector2(0, 8), Vector2(W * 0.54, H * 0.48), Color(0.08, 0.035, 0.025, 0.26 * alpha))
	match ingredient_id:
		"dough": _draw_dough(alpha)
		"sauce": _draw_sauce(alpha)
		"mozzarella", "extra_cheese": _draw_cheese(alpha, ingredient_id == "extra_cheese")
		"pepperoni": _draw_pepperoni(alpha)
		"mushrooms": _draw_mushrooms(alpha)
		"pineapple": _draw_pineapple(alpha)
		"ham": _draw_ham(alpha)
		"sausage": _draw_sausage(alpha)
		"herbs": _draw_herbs(alpha)
		_: _draw_dough(alpha)

func _draw_dough(a: float) -> void:
	_draw_oval_layer(Color(0.43, 0.19, 0.08, a), W * 0.56, H * 0.52, 0.10)
	_draw_oval_layer(Color(0.89, 0.57, 0.25, a), W * 0.53, H * 0.43, 0.07)
	_draw_oval_layer(Color(1.0, 0.79, 0.43, a), W * 0.49, H * 0.30, 0.04)
	for i in range(7):
		var x := (float(i) - 3.0) * 21.0
		_draw_ellipse(Vector2(x, -3.5 + sin(float(i) * 2.1) * 2.0), Vector2(3.2, 1.6), Color(0.64, 0.32, 0.13, a))
	_draw_highlight(a)

func _draw_sauce(a: float) -> void:
	_draw_oval_layer(Color(0.58, 0.12, 0.12, a), W * 0.54, H * 0.40, 0.08)
	_draw_oval_layer(Color(0.86, 0.20, 0.17, a), W * 0.51, H * 0.31, 0.06)
	for i in range(5):
		var x := -57.0 + float(i) * 27.0
		_draw_ellipse(Vector2(x, -5.0 + sin(i * 3.0) * 1.4), Vector2(10, 2.5), Color(1.0, 0.48, 0.34, 0.6 * a))
	_draw_highlight(a)

func _draw_cheese(a: float, extra: bool) -> void:
	var height_scale := 1.0 if not extra else 1.3
	_draw_oval_layer(Color(0.76, 0.52, 0.20, a), W * 0.54, H * 0.43 * height_scale, 0.09)
	_draw_oval_layer(Color(1.0, 0.87, 0.53, a), W * 0.51, H * 0.35 * height_scale, 0.08)
	_draw_oval_layer(Color(1.0, 0.96, 0.75, a), W * 0.47, H * 0.25 * height_scale, 0.05)
	for i in range(6):
		var x := -61.0 + float(i) * 24.0
		draw_circle(Vector2(x, 2.0 + sin(float(i) * 4.0) * 1.5), 3.0, Color(0.98, 0.77, 0.36, 0.75 * a))
	_draw_highlight(a)

func _draw_pepperoni(a: float) -> void:
	_draw_base_topping(a, Color(0.79, 0.18, 0.18, a))
	for i in range(6):
		var x := -62.0 + float(i) * 24.0
		var y := -7.0 + sin(float(i) * 2.6) * 2.0
		_draw_ellipse(Vector2(x, y), Vector2(10.0, 6.7), Color(0.42, 0.09, 0.09, a))
		_draw_ellipse(Vector2(x, y - 0.8), Vector2(8.2, 5.0), Color(0.87, 0.25, 0.22, a))
		for spot in range(3):
			draw_circle(Vector2(x - 3.0 + spot * 3.0, y + sin(float(spot) * 4.0) * 1.8), 0.9, Color(1.0, 0.68, 0.39, a))
	_draw_highlight(a)

func _draw_mushrooms(a: float) -> void:
	_draw_base_topping(a, Color(0.88, 0.74, 0.54, a))
	for i in range(5):
		var x := -54.0 + float(i) * 26.0
		var y := -6.0 + sin(float(i) * 2.3) * 2.0
		draw_arc(Vector2(x, y), 8.0, PI, TAU, 16, Color(0.53, 0.35, 0.22, a), 3.0, true)
		draw_line(Vector2(x - 6, y), Vector2(x + 6, y), Color(0.97, 0.88, 0.71, a), 4.0, true)
		draw_line(Vector2(x, y - 1), Vector2(x + 1, y + 5), Color(0.63, 0.46, 0.31, a), 1.5, true)
	_draw_highlight(a)

func _draw_pineapple(a: float) -> void:
	_draw_base_topping(a, Color(0.91, 0.64, 0.18, a))
	for i in range(7):
		var x := -68.0 + float(i) * 22.0
		var y := -7.0 + sin(float(i) * 3.1) * 4.0
		var points := PackedVector2Array([Vector2(x - 5, y - 4), Vector2(x + 4, y - 5), Vector2(x + 7, y + 2), Vector2(x + 1, y + 5), Vector2(x - 5, y + 2)])
		draw_colored_polygon(points, Color(1.0, 0.79, 0.23, a))
		draw_line(Vector2(x - 2, y - 1), Vector2(x + 3, y), Color(1.0, 0.91, 0.49, a), 1.4, true)
	_draw_highlight(a)

func _draw_ham(a: float) -> void:
	_draw_base_topping(a, Color(0.73, 0.31, 0.33, a))
	for i in range(6):
		var x := -63.0 + float(i) * 25.0
		var y := -7.0 + sin(float(i) * 2.7) * 3.0
		var points := PackedVector2Array([Vector2(x - 8, y - 3), Vector2(x - 3, y - 7), Vector2(x + 7, y - 4), Vector2(x + 8, y + 2), Vector2(x + 1, y + 6), Vector2(x - 8, y + 3)])
		draw_colored_polygon(points, Color(0.94, 0.54, 0.53, a))
		draw_arc(Vector2(x, y), 3.2, 0.2, 2.7, 12, Color(1.0, 0.78, 0.70, a), 1.2, true)
	_draw_highlight(a)

func _draw_sausage(a: float) -> void:
	_draw_base_topping(a, Color(0.42, 0.22, 0.13, a))
	for i in range(7):
		var x := -67.0 + float(i) * 22.0
		var y := -6.0 + sin(float(i) * 3.3) * 3.0
		_draw_ellipse(Vector2(x, y), Vector2(8.0, 5.8), Color(0.50, 0.27, 0.16, a))
		_draw_ellipse(Vector2(x - 1.0, y - 1.0), Vector2(5.0, 2.2), Color(0.76, 0.48, 0.27, a))
	_draw_highlight(a)

func _draw_herbs(a: float) -> void:
	_draw_base_topping(a, Color(0.86, 0.78, 0.42, a))
	for i in range(13):
		var x := -69.0 + float((i * 17) % 139)
		var y := -7.0 + sin(float(i) * 2.4) * 7.0
		var leaf := Color(0.20, 0.52, 0.27, a) if i % 2 == 0 else Color(0.37, 0.69, 0.32, a)
		draw_line(Vector2(x - 3, y + 2), Vector2(x + 3, y - 2), leaf, 2.5, true)
		draw_circle(Vector2(x + 2, y - 2), 1.5, leaf)
	_draw_highlight(a)

func _draw_base_topping(a: float, color: Color) -> void:
	_draw_oval_layer(Color(0.67, 0.43, 0.18, a), W * 0.54, H * 0.40, 0.07)
	_draw_oval_layer(color, W * 0.51, H * 0.31, 0.05)

func _draw_oval_layer(color: Color, rx: float, ry: float, wave: float) -> void:
	var points := PackedVector2Array()
	for i in range(48):
		var angle := TAU * float(i) / 48.0
		var wobble := 1.0 + sin(angle * 7.0) * wave + cos(angle * 11.0) * wave * 0.45
		points.append(Vector2(cos(angle) * rx * wobble, sin(angle) * ry * wobble))
	draw_colored_polygon(points, color)
	points.append(points[0])
	draw_polyline(points, Color(0.35, 0.16, 0.09, color.a), 1.6, true)

func _draw_highlight(a: float) -> void:
	draw_line(Vector2(-61, -8), Vector2(48, -10), Color(1.0, 0.91, 0.69, 0.34 * a), 1.8, true)

func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(36):
		var angle := TAU * float(i) / 36.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)

extends CanvasLayer

signal play_pressed
signal retry_pressed
signal menu_pressed

const IngredientScene = preload("res://scenes/ingredient.tscn")
const Recipes = preload("res://data/recipes.gd")

var root_control: Control
var menu_panel: PanelContainer
var hud_panel: PanelContainer
var result_panel: PanelContainer
var best_label: Label
var score_label: Label
var recipe_label: Label
var ingredient_label: Label
var next_label: Label
var height_label: Label
var stability_bar: ProgressBar
var stability_label: Label
var preview: IngredientView
var result_title: Label
var result_stats: Label
var result_feedback: Label
var result_record: Label

func _ready() -> void:
	_build_ui()

func show_menu(best_score: int) -> void:
	menu_panel.visible = true
	hud_panel.visible = false
	result_panel.visible = false
	best_label.text = "BEST SCORE  %s" % _format_score(best_score)

func show_game() -> void:
	menu_panel.visible = false
	hud_panel.visible = true
	result_panel.visible = false

func show_results(stats: Dictionary) -> void:
	menu_panel.visible = false
	hud_panel.visible = false
	result_panel.visible = true
	result_title.text = "PIZZA DISASTER!"
	result_stats.text = "SCORE  %s\nHEIGHT  %d layers\nRECIPES  %d completed" % [_format_score(int(stats.get("score", 0))), int(stats.get("height", 0)), int(stats.get("recipes", 0))]
	result_feedback.text = str(stats.get("feedback", "Keep stacking!"))
	result_record.text = "NEW RECORD!" if bool(stats.get("record_broken", false)) else "BEST SCORE  %s" % _format_score(int(stats.get("best_score", 0)))

func update_hud(stats: Dictionary) -> void:
	if score_label == null:
		return
	score_label.text = _format_score(int(stats.get("score", 0)))
	height_label.text = "HEIGHT  %02d    RECIPES  %d" % [int(stats.get("height", 0)), int(stats.get("recipes", 0))]
	recipe_label.text = str(stats.get("recipe", "Pepperoni Classic"))
	ingredient_label.text = str(stats.get("ingredient", "Dough"))
	next_label.text = "NEXT  %s" % str(stats.get("next_ingredient", "Tomato sauce"))
	var stability := float(stats.get("stability", 1.0))
	stability_bar.value = stability * 100.0
	stability_label.text = "BALANCE  %d%%" % int(stability * 100.0)
	if preview != null:
		preview.setup(_ingredient_id_from_label(ingredient_label.text), true)

func _build_ui() -> void:
	root_control = Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	menu_panel = _card(Vector2(460, 500))
	root_control.add_child(menu_panel)
	var menu := VBoxContainer.new()
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu.add_theme_constant_override("separation", 17)
	menu_panel.add_child(menu)
	menu.add_child(_spacer(12))
	var eyebrow := _label("ARCADE PIZZERIA", 16, Color("b35336"), HORIZONTAL_ALIGNMENT_CENTER)
	menu.add_child(eyebrow)
	var title := _label("PIZZA\n& CHAOS", 54, Color("4b2630"), HORIZONTAL_ALIGNMENT_CENTER)
	title.add_theme_font_size_override("font_size", 54)
	menu.add_child(title)
	var subtitle := _label("Stack it high. Keep it balanced.", 18, Color("795746"), HORIZONTAL_ALIGNMENT_CENTER)
	menu.add_child(subtitle)
	menu.add_child(_spacer(3))
	var play := _button("LET'S COOK!", true)
	play.pressed.connect(func(): play_pressed.emit())
	menu.add_child(play)
	best_label = _label("BEST SCORE  0", 15, Color("795746"), HORIZONTAL_ALIGNMENT_CENTER)
	menu.add_child(best_label)
	var footer := _label("A  /  D     MOVE        SPACE     DROP", 13, Color("9c7359"), HORIZONTAL_ALIGNMENT_CENTER)
	menu.add_child(footer)
	menu.add_child(_spacer(7))

	hud_panel = _card(Vector2(360, 225))
	hud_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	hud_panel.position = Vector2(24, 24)
	hud_panel.size = Vector2(360, 225)
	hud_panel.visible = false
	root_control.add_child(hud_panel)
	var hud := VBoxContainer.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_theme_constant_override("separation", 7)
	hud_panel.add_child(hud)
	var row := HBoxContainer.new()
	hud.add_child(row)
	var score_box := VBoxContainer.new()
	row.add_child(score_box)
	score_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_box.add_child(_label("SCORE", 12, Color("98705a")))
	score_label = _label("000000", 30, Color("4b2630"))
	score_box.add_child(score_label)
	var preview_box := VBoxContainer.new()
	row.add_child(preview_box)
	preview_box.custom_minimum_size.x = 105
	preview = IngredientScene.instantiate() as IngredientView
	preview.setup("dough", true)
	preview.scale = Vector2(0.48, 0.48)
	preview.position = Vector2(50, 23)
	preview_box.add_child(preview)
	ingredient_label = _label("Dough", 12, Color("725144"), HORIZONTAL_ALIGNMENT_CENTER)
	preview_box.add_child(ingredient_label)
	recipe_label = _label("Pepperoni Classic", 19, Color("6a342f"))
	hud.add_child(recipe_label)
	next_label = _label("NEXT  Tomato sauce", 13, Color("98705a"))
	hud.add_child(next_label)
	height_label = _label("HEIGHT  00    RECIPES  0", 13, Color("765747"))
	hud.add_child(height_label)
	stability_label = _label("BALANCE  100%", 12, Color("537853"))
	hud.add_child(stability_label)
	stability_bar = ProgressBar.new()
	stability_bar.custom_minimum_size.y = 13
	stability_bar.max_value = 100
	stability_bar.value = 100
	stability_bar.show_percentage = false
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("59a06a")
	fill.corner_radius_top_left = 7
	fill.corner_radius_top_right = 7
	fill.corner_radius_bottom_left = 7
	fill.corner_radius_bottom_right = 7
	stability_bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color("ead9c2")
	bg.corner_radius_top_left = 7
	bg.corner_radius_top_right = 7
	bg.corner_radius_bottom_left = 7
	bg.corner_radius_bottom_right = 7
	stability_bar.add_theme_stylebox_override("background", bg)
	hud.add_child(stability_bar)

	result_panel = _card(Vector2(440, 470))
	result_panel.visible = false
	root_control.add_child(result_panel)
	var results := VBoxContainer.new()
	results.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	results.add_theme_constant_override("separation", 17)
	result_panel.add_child(results)
	results.add_child(_spacer(8))
	result_title = _label("PIZZA DISASTER!", 36, Color("a73831"), HORIZONTAL_ALIGNMENT_CENTER)
	results.add_child(result_title)
	result_stats = _label("SCORE  0\nHEIGHT  0 layers\nRECIPES  0 completed", 19, Color("4b2630"), HORIZONTAL_ALIGNMENT_CENTER)
	results.add_child(result_stats)
	result_feedback = _label("A tower worthy of a chef.", 15, Color("795746"), HORIZONTAL_ALIGNMENT_CENTER)
	results.add_child(result_feedback)
	result_record = _label("BEST SCORE  0", 15, Color("b35336"), HORIZONTAL_ALIGNMENT_CENTER)
	results.add_child(result_record)
	var retry := _button("STACK AGAIN", true)
	retry.pressed.connect(func(): retry_pressed.emit())
	results.add_child(retry)
	var menu_button := _button("MAIN MENU", false)
	menu_button.pressed.connect(func(): menu_pressed.emit())
	results.add_child(menu_button)

func _card(size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = size
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -size.x * 0.5
	panel.offset_right = size.x * 0.5
	panel.offset_top = -size.y * 0.5
	panel.offset_bottom = size.y * 0.5
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 0.96, 0.87, 0.96)
	style.border_color = Color("e0bd8d")
	style.set_border_width_all(2)
	style.set_corner_radius_all(22)
	style.content_margin_left = 30
	style.content_margin_right = 30
	style.content_margin_top = 24
	style.content_margin_bottom = 24
	style.shadow_color = Color(0.18, 0.09, 0.08, 0.18)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 8)
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 58)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color("fff8e9") if primary else Color("70463b"))
	button.add_theme_color_override("font_hover_color", Color("fff8e9"))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("c84a37") if primary else Color("f0dfc4")
	normal.set_corner_radius_all(16)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("df6344") if primary else Color("e6c99f")
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("a83a31") if primary else Color("d8b788")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	return button

func _label(text: String, size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _spacer(height: float) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size.y = height
	return spacer

func _format_score(value: int) -> String:
	return "%06d" % value

func _ingredient_id_from_label(label: String) -> String:
	for key in ["dough", "sauce", "mozzarella", "pepperoni", "mushrooms", "pineapple", "ham", "sausage", "herbs", "extra_cheese"]:
		var data := Recipes.ingredient_data(key)
		if data["label"] == label:
			return key
	return "dough"

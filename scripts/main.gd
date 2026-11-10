extends Node2D

const SaveData = preload("res://scripts/gameplay/save_data.gd")

@onready var stack_game = $StackGame
@onready var ui = $UI

func _ready() -> void:
	stack_game.stats_changed.connect(ui.update_hud)
	stack_game.round_finished.connect(_on_round_finished)
	ui.play_pressed.connect(_start_game)
	ui.retry_pressed.connect(_start_game)
	ui.menu_pressed.connect(_show_menu)
	ui.show_menu(int(SaveData.load_stats().get("best_score", 0)))

func _start_game() -> void:
	ui.show_game()
	stack_game.start_round()

func _show_menu() -> void:
	stack_game.show_menu_background()
	ui.show_menu(int(SaveData.load_stats().get("best_score", 0)))

func _on_round_finished(stats: Dictionary) -> void:
	ui.show_results(stats)

class_name LandingBurst
extends Node2D

var age := 0.0
const DURATION := 0.48

func play(world_position: Vector2) -> void:
	position = world_position
	set_process(true)
	queue_redraw()

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	age += delta
	queue_redraw()
	if age >= DURATION:
		queue_free()

func _draw() -> void:
	var t := clampf(age / DURATION, 0.0, 1.0)
	var alpha := 1.0 - t
	var radius := lerpf(12.0, 62.0, t)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 36, Color(1.0, 0.84, 0.43, alpha * 0.8), 3.0 * alpha, true)
	for i in range(9):
		var angle := TAU * float(i) / 9.0
		var direction := Vector2(cos(angle), sin(angle))
		var start := direction * lerpf(9.0, 22.0, t)
		var end := direction * lerpf(25.0, 72.0, t)
		draw_line(start, end, Color(1.0, 0.68, 0.31, alpha), 2.4 * alpha, true)
		draw_circle(end, lerpf(3.2, 1.2, t), Color(1.0, 0.93, 0.67, alpha))

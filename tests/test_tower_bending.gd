extends SceneTree

const Bending = preload("res://scripts/physics/tower_bending.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var failures: Array[String] = []
	var right_offsets: Array[float] = [0.0, 12.0, 12.0, 12.0]
	var left_offsets: Array[float] = [0.0, -12.0, -12.0, -12.0]
	_check("bottom dough centerline stays exactly anchored", is_zero_approx(Bending.centerline_curve([0.0, 220.0, -180.0])[0]), failures)
	_check("bottom dough world x can be held at zero", is_zero_approx(Bending.world_x_positions([0.0, 12.0, -5.0])[0]), failures)
	_check("positive offsets bend right above the base", Bending.centerline_at_height(right_offsets, 4) > 0.0, failures)
	_check("negative offsets bend left above the base", Bending.centerline_at_height(left_offsets, 4) < 0.0, failures)
	var cancelling: Array[float] = [0.0, 15.0, -10.0]
	var cancellation_profile := Bending.section_moments(cancelling)
	_check("positive and negative weighted moments cancel at the upper section", is_equal_approx(cancellation_profile[2], 0.0), failures)
	var alternating_height := Bending.centerline_at_height([0.0, 15.0, -10.0, 0.0], 4)
	var one_sided_height := Bending.centerline_at_height([0.0, 15.0, 15.0, 0.0], 4)
	_check("alternating offsets reduce upper bending", absf(alternating_height) < absf(one_sided_height), failures)
	_check("height leverage makes the upper centerline bend farther", Bending.centerline_at_height([0.0, 12.0, 12.0], 3) > Bending.centerline_at_height([0.0, 12.0], 2), failures)
	var existing: Array[float] = [0.0, 18.0, -4.0]
	var old_positions := Bending.world_x_positions(existing)
	var extended: Array[float] = [0.0, 18.0, -4.0, 30.0]
	var new_positions := Bending.world_x_positions(extended)
	var prior_layers_unchanged := true
	for i in range(old_positions.size()):
		prior_layers_unchanged = prior_layers_unchanged and is_equal_approx(old_positions[i], new_positions[i])
	_check("adding a new placement does not move existing layers", prior_layers_unchanged, failures)
	var curve := Bending.centerline_curve(extended)
	var offsets_retained := true
	for i in range(extended.size()):
		offsets_retained = offsets_retained and is_equal_approx(new_positions[i] - curve[i], extended[i])
	_check("each ingredient keeps its relative centerline offset", offsets_retained, failures)
	_check("balanced tower has full stability", is_equal_approx(Bending.stability([0.0, 0.0, 0.0]), 1.0), failures)
	_check("higher same-direction load lowers stability", Bending.stability([0.0, 15.0, 15.0, 15.0]) < Bending.stability([0.0, 15.0]), failures)
	_check("large moment reaches the structural instability limit", Bending.is_unstable([0.0, 140.0, 140.0]), failures)
	var report: Dictionary = Bending.stability_report([0.0, 60.0, 45.0])
	_check("stability reports the critical support height", int(report["critical_height"]) > 0, failures)
	if failures.is_empty():
		print("PASS: 13 tower-physics scenarios")
		quit(0)
		return
	for failure in failures:
		push_error("FAIL: " + failure)
	quit(1)

func _check(label: String, passed: bool, failures: Array[String]) -> void:
	if not passed:
		failures.append(label)

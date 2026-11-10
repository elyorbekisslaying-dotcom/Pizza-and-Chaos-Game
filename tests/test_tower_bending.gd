extends SceneTree

const Bending = preload("res://scripts/physics/tower_bending.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var failures: Array[String] = []
	_check("central placements stay straight", is_equal_approx(Bending.top_displacement([0.0, 0.0, 0.0]), 0.0), failures)
	_check("right placements bend right", Bending.top_displacement([12.0, 12.0, 12.0]) > 0.0, failures)
	_check("left placements bend left", Bending.top_displacement([-12.0, -12.0, -12.0]) < 0.0, failures)
	_check("alternating offsets partly cancel", absf(Bending.signed_moment([10.0, -10.0, 10.0])) < absf(Bending.signed_moment([10.0, 10.0, 10.0])), failures)
	_check("equal opposite offsets partly cancel after leverage", absf(Bending.signed_moment([10.0, -10.0])) < absf(Bending.signed_moment([10.0, 10.0])), failures)
	_check("weighted positive and negative offsets cancel", is_equal_approx(Bending.signed_moment([10.0, -5.0]), 0.0), failures)
	_check("taller imbalance bends more", Bending.top_displacement([10.0, 10.0, 10.0, 10.0]) > Bending.top_displacement([10.0, 10.0]), failures)
	_check("larger imbalance lowers stability", Bending.stability([80.0, 80.0]) < Bending.stability([10.0, 10.0]), failures)
	_check("large imbalance reaches instability", Bending.is_unstable([140.0, 140.0]), failures)
	var curve := Bending.centerline_curve([12.0, 12.0, 12.0])
	_check("curve grows smoothly from base to top", curve[0] < curve[1] and curve[1] < curve[2], failures)
	if failures.is_empty():
		print("PASS: 10 tower-bending scenarios")
		quit(0)
		return
	for failure in failures:
		push_error("FAIL: " + failure)
	quit(1)

func _check(label: String, passed: bool, failures: Array[String]) -> void:
	if not passed:
		failures.append(label)

extends SceneTree

const StackLogic = preload("res://scripts/physics/stack_balance.gd")
const Balance = preload("res://data/game_balance.gd")

func _initialize() -> void:
	var failures: Array[String] = []
	_check("one topping is supported", not StackLogic.is_unstable([0.0, 0.0]), failures)
	_check("centered stack remains balanced", not StackLogic.is_unstable([0.0, 12.0, 4.0, -5.0]), failures)
	_check("overhanging layer retains physical overlap", StackLogic.has_support_overlap(0.0, 120.0), failures)
	_check("gap beyond collision width loses support", not StackLogic.has_support_overlap(0.0, 175.0), failures)
	_check("large overhang triggers collapse", StackLogic.is_unstable([0.0, 140.0]), failures)
	_check("upper center of mass can destabilize a lower layer", StackLogic.is_unstable([0.0, 10.0, 115.0]), failures)
	_check("mixed placements can counterbalance the stack", not StackLogic.is_unstable([0.0, 42.0, 0.0, -42.0]), failures)
	_check("center of mass is computed from placed layers", is_equal_approx(StackLogic.center_of_mass([0.0, 30.0, 60.0]), 30.0), failures)
	_check("empty center of mass is safe", is_zero_approx(StackLogic.center_of_mass([])), failures)
	if failures.is_empty():
		print("PASS: 9 support and balance scenarios")
		quit(0)
		return
	for failure in failures:
		push_error("FAIL: " + failure)
	quit(1)

func _check(label: String, passed: bool, failures: Array[String]) -> void:
	if not passed:
		failures.append(label)

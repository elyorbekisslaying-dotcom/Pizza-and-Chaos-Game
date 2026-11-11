class_name StackBalance
extends RefCounted
## Predictable balance checks for a vertical stack of equal-mass pizza layers.

const Balance = preload("res://data/game_balance.gd")

static func has_support_overlap(left_x: float, right_x: float, width: float = Balance.INGREDIENT_WIDTH) -> bool:
	return width - absf(right_x - left_x) >= Balance.MIN_SUPPORT_OVERLAP

## Checks whether each supporting layer can hold the center of mass above it.
## A small safety margin makes a visibly overhanging tower tip before it is
## mathematically at the edge, so loss of balance is readable to the player.
static func is_unstable(centers: Array[float], width: float = Balance.INGREDIENT_WIDTH) -> bool:
	if centers.size() < 2:
		return false
	for i in range(centers.size() - 1):
		var support_x := centers[i]
		var next_x := centers[i + 1]
		if not has_support_overlap(support_x, next_x, width):
			return true
		var sum_x := 0.0
		for j in range(i + 1, centers.size()):
			sum_x += centers[j]
		var center_of_mass := sum_x / float(centers.size() - i - 1)
		if absf(center_of_mass - support_x) > width * Balance.BALANCE_MARGIN:
			return true
	return false

static func center_of_mass(centers: Array[float]) -> float:
	if centers.is_empty():
		return 0.0
	var total := 0.0
	for x in centers:
		total += x
	return total / float(centers.size())

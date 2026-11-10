class_name TowerBending
extends RefCounted
## Pure deterministic math for the whole stack. No scene tree, time, or RNG access.

const Balance = preload("res://data/game_balance.gd")
const BEND_PER_MOMENT: float = Balance.BEND_PER_MOMENT
const MAX_BEND_PIXELS: float = Balance.MAX_BEND_PIXELS
const STABILITY_CAPACITY_PER_LAYER: float = Balance.STABILITY_CAPACITY_PER_LAYER

## Each offset is in pixels relative to the centerline at landing. Equal mass is 1.
## Height leverage uses one-based layer indices so higher placements contribute more.
static func signed_moment(offsets: Array[float]) -> float:
	var moment := 0.0
	for i in range(offsets.size()):
		moment += offsets[i] * float(i + 1)
	return moment

## Returns a smooth parabolic centerline displacement at a normalized tower height.
static func centerline_offset(offsets: Array[float], height_fraction: float) -> float:
	if offsets.is_empty():
		return 0.0
	var t := clampf(height_fraction, 0.0, 1.0)
	var raw_bend := signed_moment(offsets) * BEND_PER_MOMENT
	return clampf(raw_bend, -MAX_BEND_PIXELS, MAX_BEND_PIXELS) * t * t

static func top_displacement(offsets: Array[float]) -> float:
	return centerline_offset(offsets, 1.0)

static func stability(offsets: Array[float]) -> float:
	if offsets.is_empty():
		return 1.0
	var capacity := STABILITY_CAPACITY_PER_LAYER * float(offsets.size())
	return clampf(1.0 - absf(signed_moment(offsets)) / capacity, 0.0, 1.0)

static func is_unstable(offsets: Array[float], minimum_stability: float = 0.08) -> bool:
	return not offsets.is_empty() and stability(offsets) <= minimum_stability

## Centerline displacement at each layer, bottom to top. Add each stored relative
## ingredient offset to its corresponding value when rendering the tower.
static func centerline_curve(offsets: Array[float]) -> Array[float]:
	var curve: Array[float] = []
	for i in range(offsets.size()):
		var fraction := float(i + 1) / float(offsets.size())
		curve.append(centerline_offset(offsets, fraction))
	return curve

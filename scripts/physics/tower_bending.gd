class_name TowerBending
extends RefCounted
## Deterministic discrete-beam approximation. Every ingredient has unit mass.
## A placement moment accumulates upward from the anchored base. A new placement
## therefore changes only the centerline above its own layer.

const Balance = preload("res://data/game_balance.gd")
const BEND_PER_MOMENT: float = Balance.BEND_PER_MOMENT
const MAX_BEND_PIXELS: float = Balance.MAX_BEND_PIXELS
const MAX_TILT_RADIANS: float = Balance.MAX_TILT_RADIANS
const SUPPORT_CAPACITY_BASE: float = Balance.SUPPORT_CAPACITY_BASE
const SUPPORT_CAPACITY_PER_HEIGHT_SQUARED: float = Balance.SUPPORT_CAPACITY_PER_HEIGHT_SQUARED
const LAYER_SPACING: float = Balance.LAYER_SPACING

## m = 1 for every ingredient; height leverage is measured in layer spacings.
static func placement_moments(offsets: Array[float]) -> Array[float]:
	var moments: Array[float] = []
	for i in range(offsets.size()):
		moments.append(offsets[i] * float(i + 1))
	return moments

static func signed_moment(offsets: Array[float]) -> float:
	var total := 0.0
	for moment in placement_moments(offsets):
		total += moment
	return total

## Section i contains the accumulated moments of all placements at or below it.
static func section_moments(offsets: Array[float]) -> Array[float]:
	var result: Array[float] = []
	var accumulated := 0.0
	for moment in placement_moments(offsets):
		accumulated += moment
		result.append(accumulated)
	return result

## Layer 0 is the base and is always exactly at x=0. Layer h is displaced by
## integrating the accumulated section curvature of the h lower spans.
static func centerline_at_height(offsets: Array[float], height_index: int) -> float:
	if height_index <= 0:
		return 0.0
	var moments := section_moments(offsets)
	var angle := 0.0
	var displacement := 0.0
	for section_index in range(mini(height_index, moments.size())):
		angle = clampf(angle + moments[section_index] * BEND_PER_MOMENT, -MAX_TILT_RADIANS, MAX_TILT_RADIANS)
		displacement += tan(angle) * LAYER_SPACING
	return clampf(displacement, -MAX_BEND_PIXELS, MAX_BEND_PIXELS)

## Coordinates for existing layers. The first value is always zero; appending a
## placement never changes earlier values because each height uses only lower layers.
static func centerline_curve(offsets: Array[float]) -> Array[float]:
	var curve: Array[float] = []
	for layer_index in range(offsets.size()):
		curve.append(centerline_at_height(offsets, layer_index))
	return curve

static func world_x_positions(offsets: Array[float]) -> Array[float]:
	var positions: Array[float] = []
	var curve := centerline_curve(offsets)
	for i in range(offsets.size()):
		positions.append(curve[i] + offsets[i])
	return positions

static func top_displacement(offsets: Array[float]) -> float:
	return centerline_at_height(offsets, offsets.size())

## Stability combines support demand, accumulated tilt, and the visible bend.
## Support demand is evaluated at every section, accounting for both weighted
## moment and distance from the base. Utilization 1.0 is the deterministic limit.
static func stability_report(offsets: Array[float]) -> Dictionary:
	if offsets.is_empty():
		return {"stability": 1.0, "utilization": 0.0, "critical_height": 0, "max_tilt": 0.0, "max_displacement": 0.0}
	var moments := section_moments(offsets)
	var angle := 0.0
	var max_tilt := 0.0
	var max_displacement := 0.0
	var max_utilization := 0.0
	var critical_height := 0
	for i in range(moments.size()):
		var height_from_base := float(i + 1)
		angle = clampf(angle + moments[i] * BEND_PER_MOMENT, -MAX_TILT_RADIANS, MAX_TILT_RADIANS)
		max_tilt = maxf(max_tilt, absf(angle))
		var demand := absf(moments[i]) * height_from_base
		var support_capacity := SUPPORT_CAPACITY_BASE + SUPPORT_CAPACITY_PER_HEIGHT_SQUARED * height_from_base * height_from_base
		var section_utilization := demand / support_capacity
		var displacement := absf(centerline_at_height(offsets, i + 1))
		max_displacement = maxf(max_displacement, displacement)
		var tilt_utilization := absf(angle) / MAX_TILT_RADIANS
		var bend_utilization := displacement / MAX_BEND_PIXELS
		var utilization := maxf(section_utilization, maxf(tilt_utilization, bend_utilization))
		if utilization > max_utilization:
			max_utilization = utilization
			critical_height = i + 1
	return {
		"stability": clampf(1.0 - max_utilization, 0.0, 1.0),
		"utilization": max_utilization,
		"critical_height": critical_height,
		"max_tilt": max_tilt,
		"max_displacement": max_displacement,
		"section_moments": moments,
	}

static func stability(offsets: Array[float]) -> float:
	return float(stability_report(offsets)["stability"])

static func is_unstable(offsets: Array[float]) -> bool:
	return not offsets.is_empty() and float(stability_report(offsets)["utilization"]) >= 1.0

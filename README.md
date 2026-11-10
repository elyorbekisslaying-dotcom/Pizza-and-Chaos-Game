# Pizza and Chaos Game

A colorful Godot 4 arcade game about stacking pizza ingredients while managing a deterministic, globally bending tower.

## Run

Open this directory in Godot 4.7 or newer, then run the project. You can also launch it from a terminal:

```sh
godot --path .
```

Move the active ingredient with **A/D**, the **left/right arrows**, or the mouse. Drop it with **Space** or a left click.

## Tower math

All ingredients have equal unit mass. The bottom dough is fixed at `x = 0`. Each later placement stores its signed horizontal offset `d[i]` from the current centerline; its height weighted moment is `m[i] = d[i] × (i + 1)`. The section moment at height `i` is the prefix sum `S[i] = Σ m[j]` for `j ≤ i`.

The bend angle integrates each lower section moment by `0.00075 × S[i]` radians, clamped to ±1 radian. The horizontal centerline advances by `24 × tan(angle)` pixels per span and is visually clamped to ±86 pixels. Thus the base stays fixed, accumulated lower placements bend only the tower above them, and adding a new layer leaves prior layers in place.

Stability evaluates every section’s support utilization `|S[i]| × (i + 1) / (250 + 125 × (i + 1)²)`, along with accumulated tilt and visible displacement. The meter is `clamp(1 - maximum utilization, 0, 1)`; the run ends when utilization reaches 1.0.

The formulas live in `scripts/physics/tower_bending.gd` and can run without rendering or gameplay state.

## Project map

- `scenes/`: main game and procedural ingredient scenes.
- `scripts/physics/`: pure bending and stability calculations.
- `scripts/gameplay/`: stacking, recipe progress, scoring, effects, and local records.
- `scripts/ingredients/`: procedural ingredient illustrations.
- `scripts/ui/`: main menu, gameplay HUD, and results screen.
- `data/`: ingredient recipes and shared balance constants.
- `tests/`: automated math and recipe-flow checks plus repeatable manual scenarios.

## Tests

Run from the project root:

```sh
godot --headless --path . --script tests/test_tower_bending.gd
godot --headless --path . --script tests/test_game_flow.gd
```

## Validation

Validated with Godot 4.7 stable: editor import, headless project startup, 13 bending scenarios, and 30 gameplay/control/falling/camera/recipe scenarios pass. The gameplay suite executes actual tweened drops. A manual visual playthrough was unavailable because the Godot window was minimized. Windows and Web exports have not been built or tested.

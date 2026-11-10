# Pizza and Chaos Game

A colorful Godot 4 arcade game about stacking pizza ingredients while managing a deterministic, globally bending tower.

## Run

Open this directory in Godot 4.7 or newer, then run the project. You can also launch it from a terminal:

```sh
godot --path .
```

Move the active ingredient with **A/D**, the **left/right arrows**, or the mouse. Drop it with **Space** or a left click.

## Tower math

All ingredients have equal mass. After each landing, the game stores that ingredient’s signed horizontal offset from the active centerline. The bending module computes the accumulated moment

```text
M = Σ(offset[i] × (i + 1))
```

where `i + 1` is the layer’s height leverage. The centerline at normalized height `t` moves by `clamp(0.026 × M, -86, 86) × t²`. Each ingredient is drawn at its stored relative offset from that shared curve, so the stack bends as one structure. Stability is `clamp(1 - |M| / (178 × layer_count), 0, 1)`; a run ends when it reaches 8%.

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

Validated with Godot 4.7 stable: editor import, headless project startup, 10 bending scenarios, and 5 recipe-flow scenarios pass. Windows and Web exports have not been built or tested.

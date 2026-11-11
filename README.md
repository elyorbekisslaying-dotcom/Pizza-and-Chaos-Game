# Pizza and Chaos Game

A cartoon 2D arcade game about dropping toppings onto one dough base and building the tallest balanced pizza stack.

## Run

Open this directory in Godot 4.7 or newer, then run the project. From a terminal:

```sh
godot --path .
```

The next topping sweeps left and right automatically. Aim with the mouse or **A/D** / arrow keys; drop with **Space** or left click. Toppings collide with the stack, then settle in place. Each safe placement adds a point. The stack tips when supports are lost, and ingredient speed rises as the score grows. Press **STACK AGAIN** to restart.

## Project map

- `scenes/`: main game and ingredient body.
- `scripts/physics/stack_balance.gd`: deterministic support and center of mass checks.
- `scripts/gameplay/`: round state, stacking, scoring, and local best score.
- `scripts/ingredients/`: procedural cartoon ingredient illustrations.
- `scripts/ui/`: menu, HUD, and results screen.
- `data/`: shared game balance constants.
- `tests/`: automated support and gameplay scenarios.

The dough base is a single `StaticBody2D`. Dropped toppings use rigid body gravity and collision shapes sized to their visible pizza layers. After settling, they freeze in place to prevent random sliding; an unsafe stack releases the layers so the fall is visible.

## Tests

Run from the project root:

```sh
godot --headless --path . --script tests/test_stack_balance.gd
godot --headless --path . --script tests/test_game_flow.gd
```

The tests cover balance and overhang calculations, the permanent base, automatic topping sequence, actual physics landings, scoring, speed increase, camera follow, collapse, and restart.

## Validation

Godot is not installed in this execution environment, so engine import, headless tests, and visual playthrough could not be run here. Windows and Web exports have not been built or tested.

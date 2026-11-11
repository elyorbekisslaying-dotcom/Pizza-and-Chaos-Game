# Pizza and Chaos Game: Development Instructions

## Project boundaries
- Keep the Godot project rooted at this directory. Do not add a nested project or repository.
- Keep gameplay math independent from rendering, input, and random effects.

## Architecture
- `scripts/physics/`: deterministic support and balance calculations.
- `scripts/gameplay/`: round state, ingredient placement, scoring, and best score.
- `scripts/ingredients/`: ingredient rendering and rigid body behavior.
- `scripts/ui/`: menus, HUD, and results presentation.
- `data/`: shared balance constants.
- `scenes/`: Godot scene definitions; `tests/`: headless logic tests and gameplay scenarios.

## Gameplay invariants
- Each round starts with exactly one stationary dough `StaticBody2D` foundation.
- Toppings use rigid body collisions while falling and freeze after they settle.
- Support and center of mass calculations stay deterministic and independent from rendering.
- Ingredient sequence and cosmetic appearance must not change physics results.

## Validation
- Run `godot --headless --path . --script tests/test_stack_balance.gd`.
- Run `godot --headless --path . --script tests/test_game_flow.gd`.
- Open/import the project with Godot 4.x before claiming engine validation.
- Keep `README.md` run instructions and test status accurate.
- Do not claim Windows or Web export validation unless those builds were produced and run.

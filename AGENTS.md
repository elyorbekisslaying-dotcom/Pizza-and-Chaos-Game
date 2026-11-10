# Pizza and Chaos Game: Development Instructions

## Project boundaries
- This repository is the only project to edit for this task.
- Keep the Godot project rooted at this directory. Do not add a nested project or repository.
- Keep gameplay math independent from rendering, input, and random effects.

## Architecture
- `scripts/physics/`: deterministic, testable tower-bending and stability calculations.
- `scripts/gameplay/`: round state, stacking, scoring, and progression.
- `scripts/ingredients/`: ingredient rendering and data definitions.
- `scripts/ui/`: menus, HUD, and results presentation.
- `data/`: recipes and balance constants.
- `scenes/`: Godot scenes; `tests/`: headless math tests and reproducible scenarios.

## Gameplay invariants
- Every landed ingredient has equal mass and remains fixed relative to the tower centerline.
- Never use rigid-body simulation, per-layer drift, or random motion for the stack.
- Compute bending from every signed ingredient offset and its height leverage.
- Store recipe progress separately from tower layer count, and guard recipe completion boundaries.
- Seed or omit randomness for any cosmetic variation; cosmetics must not affect gameplay results.

## Validation
- Run the headless test scene with `godot --headless --path . --script tests/test_tower_bending.gd`.
- Run recipe progression checks with `godot --headless --path . --script tests/test_game_flow.gd`.
- Open/import the project with Godot 4.x before claiming engine validation.
- Keep `README.md` run instructions and test status accurate.
- Do not claim Windows or Web export validation unless those builds were produced and run.

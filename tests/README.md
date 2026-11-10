# Bending model checks

Run the automated suite from the repository root:

```sh
godot --headless --path . --script tests/test_tower_bending.gd
godot --headless --path . --script tests/test_game_flow.gd
```

The test runner checks straight balance, left/right direction, cancellation under alternating and weighted offsets, growth with tower height, stability response to load, instability threshold, and a smooth base-to-top curve.

The game-flow runner checks that a round starts on dough, the Classic recipe order reaches pepperoni, completion advances to the next recipe, and that next recipe starts on dough even though the tower already has four layers.

## Reproducible interactive checks

1. Start a round and place every ingredient with the active piece centered. The centerline should remain straight.
2. Place several pieces to the right with **D**. The whole stack should curve right; repeat to the left with **A**.
3. Alternate between left and right offsets. The curve should reduce compared with placing every ingredient to one side.
4. Use the mouse to aim and click, or use **A/D** and **Space**. Landed pieces should keep their relative positions while the full centerline eases to its new curve.
5. Finish the first four ingredients. Mushroom Pizza should start at dough, then progress to Hawaiian and Meat Lovers without skipping the first item.
6. Build a strongly one-sided stack. The balance meter should drain, then the run should end and persist a best score/height locally.

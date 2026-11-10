# Bending model checks

Run the automated suite from the repository root:

```sh
godot --headless --path . --script tests/test_tower_bending.gd
godot --headless --path . --script tests/test_game_flow.gd
```

The bending suite checks the anchored base, signed bending, weighted cancellation, height leverage, fixed relative offsets, no movement of existing layers after a new placement, and stability/utilization across the tower.

The gameplay suite performs four real tweened drops in headless Godot. It checks the actual fall start/target, vertical motion, base anchoring, existing-layer positions, mouse/keyboard mappings, camera motion, and recipe progression.

## Reproducible interactive checks

1. Start a round and place every ingredient with the active piece centered. The centerline should remain straight.
2. Place several pieces to the right with **D**. The whole stack should curve right; repeat to the left with **A**.
3. Alternate between left and right offsets. The curve should reduce compared with placing every ingredient to one side.
4. Use the mouse to aim and click, or use **A/D** and **Space**. Each new placement should bend only the tower above that layer; the base and already placed layers stay fixed.
5. Finish the first four ingredients. Mushroom Pizza should start at dough, then progress to Hawaiian and Meat Lovers without skipping the first item.
6. Build a strongly one-sided stack. The balance meter should drain, then the run should end and persist a best score/height locally.

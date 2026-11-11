# Gameplay checks

Run both suites from the repository root with Godot 4.7 or newer:

```sh
godot --headless --path . --script tests/test_stack_balance.gd
godot --headless --path . --script tests/test_game_flow.gd
```

The support suite checks overlap, safe center of mass, counterbalance, and instability. The gameplay suite uses real physics frames to check the single static dough base, ingredient collision and settling, automatic sequence, score and speed, camera follow, unsafe overhang collapse, and restart.

## Manual playthrough

1. Start a round and watch the topping move from side to side above the dough.
2. Drop with **Space** or left click. Use **A/D** or the arrows to guide it, or aim with the mouse.
3. Place toppings near the middle to build safely; try an overhang to see the stack tip.
4. Continue until collapse, review the score, and choose **STACK AGAIN**.

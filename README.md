# The Odyssey

The Odyssey is a custom C++ game engine project built specifically for the game.

The active runtime lives entirely in `engine/`. The repository has no dependency on a general-purpose game engine.

## Build

Requirements:
- CMake 3.20+
- C++20 compiler
- internet access on first configure so CMake can fetch Raylib 5.5

```bash
cmake -S . -B build
cmake --build build --config Release
```

Run the resulting `odyssey` executable.

## Current engine goals

1. Stable third-person physics.
2. Automatic step-up for low obstacles.
3. Contextual climbing on steep surfaces.
4. Independent water movement and buoyancy.
5. Systemic world simulation.
6. Mobile and web backends after the desktop physics slice is stable.

See `docs/OWN_ENGINE_ARCHITECTURE.md`.

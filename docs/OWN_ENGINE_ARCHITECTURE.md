# The Odyssey — Own Engine Architecture

The Godot prototype is now treated as legacy reference. The active runtime is a small C++ engine owned by this project.

## Boundary

The Odyssey engine owns player movement, collision response, step-up traversal, climbing state, swimming, camera control, world simulation, and game rendering orchestration.

Raylib is only the low-level window/input/graphics backend in the first implementation. Game rules do not depend on Godot.

## Runtime

Input -> Game -> Physics/Traversal -> World State -> Renderer -> platform backend

The physics layer is deliberately independent from rendering so a future OpenGL/WebGL/mobile backend can replace the current backend without rewriting movement.

## Physics contract

The player is a continuous capsule-like body. Each fixed frame:
1. Convert camera-relative input into desired horizontal velocity.
2. Apply acceleration/deceleration.
3. Test the requested displacement.
4. If blocked, test a controlled vertical lift up to stepHeight and then test forward clearance.
5. If a climbable surface is detected by lower/upper body probes, enter climbing instead of jumping.
6. Water switches to a separate buoyant controller.
7. Ground contact resolves against one continuous base plane.

There is no post-move global-Y correction pass.

## First slice

The current executable contains:
- third-person camera;
- stable horizontal acceleration;
- jump/gravity;
- automatic low-obstacle step-up;
- contextual climbing;
- water movement and buoyancy;
- procedural Greek-coast test geometry.

## Roadmap

0.1: engine loop, physics, camera, procedural test world.
0.2: proper skinned character, animation state machine, camera collision and foot placement.
0.3: chunked terrain, world streaming, vegetation, water volumes and boats.
0.4: systemic rigid-body interactions, gathering, construction, crafting and wildlife.
0.5: mobile touch controls and performance profiles.
0.6: web backend and browser packaging.

The target is a game-specific systemic engine, not a general-purpose editor.

# The Odyssey — Game Design Direction

## Target

A mobile-first, third-person open-world adventure inspired by the freedom and systemic problem solving of modern physics-driven Zelda games, while using original Greek/Epic setting, characters, art and mechanics.

The design rule is:

> If the player can plausibly attempt something in the physical world, the game should usually allow the attempt.

## Core loop

Explore -> discover -> gather -> improvise/craft -> traverse -> interact -> build -> travel -> form relationships -> uncover myth -> return home.

## Feature map

- **Traversal:** climbing, swimming, diving, jumping, sprinting and contextual movement.
- **Physics:** carry, push, pull, throw, cut, burn, connect with rope and construct objects.
- **Crafting:** tools, meals, camp equipment, ladders, bridges, rafts and storage.
- **Construction:** place structures where the environment makes them useful instead of following a fixed quest corridor.
- **Survival-lite:** hunger, warmth, fatigue, exposure, weather, fire, cooking and rest.
- **Transportation:** raft first, then ships and other discovered transport.
- **Exploration:** revealed map regions and discovery-gated fast travel.
- **Cities:** settlements with merchants, craftsmen, sailors, quests and social consequences.
- **Wildlife:** roaming animals and environmental encounters.
- **Mythology:** gods, sacred places, monsters and consequences tied to exploration.
- **Underwater:** caves, reefs, wrecks, submerged ruins and underwater routes.
- **Underworld:** a distinct mythic realm connected to the dead and the homecoming.
- **Heavens:** high mythic locations and divine domains.
- **Calypso:** a major island/relationship arc discovered through travel.
- **Relationships:** characters track trust/rivalry/alliance values rather than being simple quest dispensers.
- **Ithaca:** the journey has a real homecoming endpoint.
- **Generational epilogue:** the world reflects what happened after the homecoming.

## Mobile UX

- Left virtual stick: movement.
- Right side drag: camera.
- Large contextual action buttons: jump, interact and action.
- No keyboard is required for gameplay.
- UI is designed around landscape phone/tablet play.

## Art direction

Stylized Mediterranean realism: warm stone, weathered wood, dense green foliage, bright Aegean water, readable silhouettes, strong sunlight, atmospheric distance and original character designs.

Do not use Zelda assets, copied characters, logos, maps, music or other copyrighted game content.

## Performance target

Godot 4 Web with the compatibility renderer. Prefer low-poly meshes, shared materials, simple collision, object pooling/streaming for larger worlds, and deterministic systems that can later be persisted through Supabase.

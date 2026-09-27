# The Odyssey — Mobile Open-World Adventure

Godot 4.x foundation for an emergent, physically-inspired open-world Odyssey.

Implemented:
- Capability-based world objects and interactions.
- Physics-aware grabbing, throwing and construction.
- Resource harvesting and destruction.
- Fire and rope systems.
- Bulk-material inventory with limited equipment capacity.
- Crafting, climbing, swimming/diving and weather foundations.
- Discovery-gated fast travel.
- Godot Web export.
- GitHub Actions CI/build and GitHub Pages Web deployment.
- Supabase REST client foundation and RLS-protected persistent world-state schema.

## Automatic deployment

.github/workflows/deploy.yml builds the Godot Web export on pull requests and deploys the game to GitHub Pages on pushes to main.

Required GitHub repository Actions secrets:
- INFINITYFREE_FTP_SERVER
- INFINITYFREE_FTP_USERNAME
- INFINITYFREE_FTP_PASSWORD
- INFINITYFREE_FTP_SERVER_DIR
- SUPABASE_URL
- SUPABASE_ANON_KEY

Do not commit FTP passwords, database passwords, Supabase service-role keys, or other privileged credentials.

## InfinityFree

Create the site in InfinityFree, copy the exact FTPS host, username, password and target directory from its FTP/account panel, and store them as the four INFINITYFREE_* repository secrets. Do not guess the server directory.

After this branch is merged into main, every push to main will build the Web game and deploy it to the configured InfinityFree directory.

## Supabase

Run supabase/migrations/001_odyssey_world_state.sql in the Supabase SQL editor. It creates authenticated-player world-state storage and enables Row Level Security so players can only read/write their own row.

Use only the Supabase URL and publishable/anon key in the client. Never expose the service-role key.

## Local

Open the repository in Godot 4.x and run scenes/Main.tscn. For a browser build, use the Web export preset.

Current direction: mobile-first third-person open world with a systemic, physics-driven adventure loop. See docs/GAME_DESIGN.md for the full feature map. The current shore slice exposes the city, shrine, underwater cave, mythic gates, Calypso's island, wildlife, gathering, construction, survival foundations, climbing and swimming.

<!-- Mobile Pages deployment trigger: 2026-09-27 -->

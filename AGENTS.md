# Repository Guidelines

## Project Structure & Module Organization
Primary firmware lives under `esphome/`. `esphome/*.yaml` files are the build entry points; `esphome/components/` hosts shared includes for sensors, controls, hardware wiring; `esphome/scripts/` contains control loops for humidity, airflow, and lighting. `assets/` serves the embedded web UI resources referenced by the ESPHome dashboard. `fixed_firmware/` and `original_shrooly_code/` archive prior Lua firmware profiles—treat them as read-only references. `memory/` and `coordination/` store agent coordination artifacts; touch them only when working on automation flows.

## Build, Test, and Development Commands
`esphome config esphome/openshrooly.yaml` validates syntax and pin assignments. `esphome compile esphome/openshrooly.yaml` builds firmware binaries locally. `esphome upload esphome/openshrooly.yaml` flashes the device (OTA when already on Wi-Fi). `esphome logs esphome/openshrooly.yaml` tails runtime logs for debugging. For the enhanced profiles, substitute `enhanced_openshrooly.yaml` or `enhanced_openshrooly_anti_mold.yaml` in the same commands.

## Coding Style & Naming Conventions
YAML uses two-space indentation, lowercase keys, and snake_case ids such as `air_exchange_manager`. Factor reusable definitions into include files rather than duplicating blocks. Keep comments concise and hardware-focused. UI assets follow kebab-case filenames and plain ES modules. When editing legacy Lua scripts, preserve CamelCase program names but document parameter changes inline.

## Testing Guidelines
Run `esphome config` before committing to catch schema regressions. Use `esphome logs` with a connected device to validate controller scripts after changes; note observed values in the PR. For display or web UI tweaks, load the generated dashboard and confirm widgets target the expected ids. No automated coverage exists, so document manual test scenarios, including humidity targets, fan cycles, and button interactions.

## Commit & Pull Request Guidelines
Commit messages in history stay short (<60 chars) and imperative (`Tune anti-mold cycle`). Group related YAML edits together and note hardware dependencies in the body. PRs should include: 1) a summary of behavioural impact, 2) the files touched (`esphome/components/...` etc.), 3) test evidence or log excerpts, and 4) screenshots for UI changes. Link related issues or discussion threads and flag breaking changes (e.g., pin remaps) in bold at the top.

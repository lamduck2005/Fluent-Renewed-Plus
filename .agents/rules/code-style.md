---
trigger: always_on
description: Luau code style for Fluent-Renewed-Plus
---
- Base: official Roblox Luau Style Guide (create.roblox.com/docs/luau/style-guide). Where this file is silent, follow it.
- Concurrency: task.wait / task.spawn / task.defer - never wait(), spawn(), delay().
- pcall around operations that can throw (e.g. file system / save / theme loading); never let unhandled errors break UI rendering.
- Naming: camelCase for locals/private fields, PascalCase for modules/components/exported APIs; no single-letter names except loop counters.
- Source of truth: Src/ and Addons/. Never hand-edit Distribution/ or generated build files.
- Comments and user-facing strings: plain ASCII. No emoji or decorative unicode unless explicitly asked.
- Comments only for non-obvious logic. Match existing file style - do not reformat unrelated code.

---
name: roblox-performance
description: Use when profiling, auditing, or optimizing Roblox game performance: low FPS, lag/stuttering, high memory, network overhead, server heartbeat drops, mobile crashes/overheating, hot path optimization, or MicroProfiler/ScriptProfiler analysis.
---

# Roblox Performance

> **Scope:** Profiling tools, performance budgets, Parallel Luau, and streaming optimization. For pooling and lifecycle patterns, see `roblox-luau-patterns`.

## Quick Reference

### Profiling Tools
- **MicroProfiler (Ctrl+F6)**: Frame breakdown of scripts, physics, rendering.
- **Developer Console (F9)**: Memory, network, rendering, and server stats.
- **Script Profiler (Ctrl+Alt+F5)**: Per-script CPU and heap.
- **Labels**: `debug.profilebegin`/`debug.profileend` mark regions; `debug.setmemorycategory` labels memory. Gate instrumentation behind a flag.

### Performance Targets
| Metric | Starting target | Investigate at |
|--------|-----------------|----------------|
| Server heartbeat | < 16ms | > 33ms |
| Client FPS (desktop) | 60 | < 30 |
| Client FPS (mobile) | 45 | < 30 |
| Memory | device-specific | sustained growth |

Optimize measured hot paths, not folklore. Throttle from measurements; re-profile after shipping.

### Parallel Luau
- Use Actors only after profiling identifies isolatable CPU work.
- Workers compute; synchronize before restricted DataModel writes.
- Do not rely on shared module state across Actors. `SendMessage` copies data; SharedTable supports shared state and atomic updates.

### Hot-loop cost model
- Luau optimizes global imports; avoid folklore function hoisting/unrolling. Environment impurity can disable optimizations. Profile allocations as well as CPU; GC cost may occur later.

### Object Pooling
Pre-clone and reuse. Canonical pool code (token-lease ownership): `roblox-luau-patterns`.

### StreamingEnabled Essentials
- **On by default**. Container-scoped: only Workspace descendants stream. `ModelStreamingBehavior = Improved` streams non-BasePart descendants with their parent Model; Legacy streams only BaseParts.
- **Streamed-out = parented to nil**, not destroyed. Luau refs persist if it streams back.
- **Config (Studio)**: target defaults 1024, min 64; set `StreamingIntegrityMode`; tune from data.
- **Gotcha**: `FindFirstChild("DistantPart")` returns nil if streamed out. Use WaitForChild with timeout.

### Mobile
- Profile geometry, textures, particles, UI, shadows on low-end devices.

> Full reference with code examples and API tables: [references/full.md](references/full.md)

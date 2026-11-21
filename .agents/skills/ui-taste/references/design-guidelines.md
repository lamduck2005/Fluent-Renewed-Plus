# Menu Design Guidelines (script-hub edition)

Curated subset of afrxo/roblox-agent-skills `skills/roblox-ui/references/design-guidelines.md` (MIT).
Trimmed for Fluent-Renewed-Plus script-hub menus: engine primitives, ScreenGui/gamepad/responsive
and token-module sections were dropped as out of scope for menus built through a UI library.

## Hierarchy

- Rank every element: primary (the one main action) > secondary (common options) > tertiary (rare / dismiss).
- Never place two primary elements side by side - split views or pick one.
- Size + weight + contrast together carry importance; don't rely on a single signal.

## Effects discipline

- Do not stack blur + glow + stroke + gradient + transparency on one surface. Pick the few that fit.
- Gradient only if it supports hierarchy; UIStroke only for readability or focus - not because a Frame "looks empty".
- One accent color. The bulk of the surface stays neutral.

## Spacing and alignment

- Reuse one gap value consistently - no magic per-element offsets.
- Items in a column share an edge or center; misalignment reads as a bug.
- Group with whitespace first; dividers and borders are a fallback, not a default.

## Text

- Body text contrast >= 4.5:1 against its background.
- Slightly off-black on slightly off-white beats pure black on pure white.
- RichText (`<b>`, `<font color="#...">`) for inline emphasis in Descriptions - don't fake it by stacking multiple TextLabels.

## States and feedback

- Every interactive element needs visible feedback: hover, pressed, disabled, loading.
- Disabled = visibly muted AND non-interactive - never "looks normal but does nothing".
- Animate state changes that affect layout; don't animate constants. Cap concurrent tweens - a long list all tweening at once is a frame-rate disaster.
- Success/error feedback: brief and inline (notification/toast from the library), never a silent failure.

## Anti-patterns (menu-relevant picks)

- One-off colors/sizes per element - reuse the theme's values.
- Drop-shadows under everything; mixed corner radii across panels.
- Decorative badges/labels the user never asked for.
- Per-frame Heartbeat UI updates - update on state change only.
- Redesigning a working menu just to prove work was done.

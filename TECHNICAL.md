# Gunti Game - Technical Reference

## Overview
Bengali traditional 2-player board game. Phaser 3 + TypeScript + Vite. 600x600 canvas. **All UI is inside the canvas** (no external DOM overlay). Only a mobile move slider remains as DOM.

## Game Rules
- **Players**: RED and BLUE (colors user-selectable). Each has **3 gutis (pieces)**.
- **Board**: 9 nodes arranged as a 3x3 grid with center, corners, and edge-midpoints. Nodes connected by lines (horizontal, vertical, diagonal, center-to-all).
- **Turn**: RED goes first. Players alternate.
- **Move**: Select own guti -> click an **adjacent connected** node. **One step only** — no jumps across two nodes.
- **Capture (eat)**: If your guti is on a node **adjacent** to an opponent's guti, tapping the opponent's node **eats/captures** it — the opponent piece is removed and your guti moves into that node (this is still one step; no jump-over-onto-empty needed).
- **No overlap**: A guti can never land on a node already occupied by your own piece. Own-occupied nodes are blocked (do nothing).
- **Win**: First player to align all 3 gutis on any of the 8 win lines (3 rows, 3 cols, 2 diagonals) wins. Checked after move 3+.
- **Capture removal**: Opponent's captured guti is removed from board state immediately, then destroyed with a fade animation.

## Board Topology (Nodes.ts)
```
TL(100,100) --- T(300,100) --- TR(500,100)
  |    \         |         /    |
L(100,300) --- C(300,300) --- R(500,300)
  |    /         |         \    |
BL(100,500) --- B(300,500) --- BR(500,500)
```
NodeKey = `T | B | L | R | TL | TR | BL | BR | C`
Each node has `links: NodeKey[]` defining valid adjacent moves.
Center `C` links to ALL 8 other nodes. Edge nodes link to center + 2 neighbors. Corners link to center + 2 edges.

## Win Lines (WinLines.ts)
8 lines of 3 nodes each. Player wins by owning all 3 nodes on any line.
```
Rows:    [TL,T,TR], [L,C,R], [BL,B,BR]
Columns: [TL,L,BL], [T,C,B], [TR,R,BR]
Diags:   [TL,C,BR], [TR,C,BL]
```

## Capture Mechanic
On `tryMove(target)`: target must be in `NODES[from].links` (**one step**). Inspect `occupied[target]`:
- empty → normal move
- opponent → `capture(target)` removes opponent (state synced immediately: gutis filtered + `occupied[target]` deleted), then `executeMove(from, target, capturedNode)` moves the selected guti in and records the captured node for undo.
- own piece → blocked (no overlap).

The previous jump-over-midpoint (`getJumpedNode`) mechanic was removed; capture is now eat-adjacent. `capture()` no longer mutates state inside the async tween callback (that caused a bug where the capturing guti was erased) — it mutates synchronously; only the sprite destruction is async.

## Canvas UI Layout (600x600)
```
┌──────────────────────────────────────────┐
│ [🔴 RED's Turn]                    [⚙]  │  ← Top bar (y=18) + Gear (575,18)
│                                          │
│  TL ──── T ──── TR                       │
│   │ ╲    │    ╱ │                        │
│  L ──── C ──── R     ← Game board       │
│   │ ╱    │    ╲ │       (100-500)        │
│  BL ──── B ──── BR                       │
│                                          │
│ [Shape: ●]              [Tap a RED guti] │  ← Bottom bar (y=582)
└──────────────────────────────────────────┘
```

### Settings Panel (opens on gear click)
Semi-transparent dark overlay (depth 200) + white panel (depth 201) centered at (300,305) 300x430.
```
┌──── ⚙ Settings ─── [✕] ────┐
│  [THEME: Classic Light]      │
│  [SOUND: ON]                 │
│  [STATS]                     │
│  [UNDO]                      │
│  [SHAPE: Circle]             │
│  [🎨 GUTI COLOR]  ← color    │
│       pair picker            │
│  [🎨 BACKGROUND] ← opens     │
│       preset grid            │
└──────────────────────────────┘
```
Click dark overlay or ✕ to close. Clicking panel buttons uses `stopPropagation()`.

### Guti Color Pair Picker (🎨 GUTI COLOR button)
Opens modal grid (depth 260+) over the settings panel. Shows **6 predefined color pairs** as two-dot swatches.
```
┌── Choose Guti Colors ───────┐
│  [● ●]Red vs Blue           │
│  [● ●]Green vs Orange       │
│  [● ●]Pink vs Teal          │
│  [● ●]Yellow vs Purple      │
│  [● ●]White vs Black        │
│  [● ●]Brown vs Cyan         │
└──────────────────────────────┘
```
Tapping a pair calls `applyColorPair(index)` — recolors both sides' gutis **in place** (preserves nodeKey/owner), and shows on the current theme's neutral colors. `GameScene.COLOR_PAIRS` static holds the pairs. Objects tracked in `colorPickerObjects[]` for cleanup.

### Background Picker (🎨 BACKGROUND button)
Opens modal grid (depth 240+) over the settings panel. **6 sample backgrounds** as thumbnails (3x2 grid) + upload option. Fully touch-friendly.
```
┌── Choose Background ────────┐
│ [🪵][🔴][🌿]                │
│ [🌙][🪨][🦖]                │
│  [ ────────────────── ]     │
│  [📁 Upload from Device ]   │
└──────────────────────────────┘
```
- Tapping a sample image sets it as the full-canvas background (depth -10, behind board).
- "Upload from Device" triggers hidden `<input type="file">`, read as base64 → Phaser Image.
- Overlay tap / ✕ closes the picker. Tracks all objects in `bgPickerObjects[]` for clean destroy.

## Default Backgrounds (BackgroundManager.ts)
6 hand-crafted illustrative backgrounds generated to textures at runtime in `create()` via `ensureGenerated()` (Phaser Graphics → `generateTexture()`). No external image files. Themed around traditional Guti game mats:
| id | label | icon | appearance |
|----|-------|------|-----------|
| teakwood | Teak Wood | 🪵 | wood fill + gradient bands + grain + carved corners |
| velvet | Velvet Red | 🔴 | rich red playing cloth + gold border + corner dots |
| greenmat | Green Mat | 🌿 | green jute mat + woven crisscross + leaf sprinkles |
| night | Moonlit Night | 🌙 | indigo sky + stars + crescent moon + hills |
| marble  | Marble    | 🪨 | light marble + veins + soft patches + border |
| dino    | Funny Dino | 🦖 | cartoon T-Rex on pastel sky + clouds + sun + ground |
Each stored in `defaultTextureKeys[id]` → texture keys `bg-teakwood`, `bg-velvet`, `bg-greenmat`, `bg-night`, `bg-marble`, `bg-dino`.

## Background Image Feature
- **6 samples**: hand-crafted illustrative textures chosen from the picker grid.
- **Upload**: gear → 🎨 BACKGROUND → 📁 Upload from Device → hidden `<input type="file" id="bg-image-input">`.
- File read as base64 DataURL → `textures.addBase64()` → Phaser Image at depth 0 (behind everything).
- **IMPORTANT**: `addBase64` loads async — listen for the `'addtexture'` ADD event (NOT `'addtexture-<key>'`) plus a 50ms `textures.exists()` polling fallback.
- Uploading a new BG or picking a preset destroys the current `bgImage` first.
- Persists until scene restart or replaced.

## File Structure
```
src/
  main.ts              - Entry. Creates Phaser.Game with gameConfig.
  config/gameConfig.ts - Phaser config: 600x600, AUTO renderer, FIT scale, GameScene.
  scenes/GameScene.ts  - Core game logic (~940 lines). All game + in-canvas UI.
  board/
    Board.ts           - Draws board lines (outer square + cross + X diagonals).
    Nodes.ts           - 9-node graph with positions and adjacency links.
    WinLines.ts        - 8 winning lines of 3 nodes.
  guti/Guti.ts         - Guti class: sprite (circle/square/bar), nodeKey, owner, moveTo(), captureAnimation().
  managers/
    ThemeManager.ts    - 5 themes (Classic Light, Dark, Ocean Blue, Sunset Gold, Purple Dream). Cycles on button.
    BackgroundManager.ts - Generates 6 sample background textures (teakwood, velvet, greenmat, night, marble, dino).
    SoundManager.ts    - Web Audio API beeps. No audio files. Methods: move, capture, win, slide(whoosh), yoo(celebration).
    StatsManager.ts    - localStorage persistence. Tracks redWins, blueWins, totalGames, averageMoves.
    MoveHistoryManager.ts - Move stack for undo. Records {player, from, to, captured}.
```

## GameScene State
```
gutis: Guti[]              - All 6 gutis on board
selectedGuti: Guti | null  - Currently selected piece
occupied: Record<NodeKey, Guti> - Which node has which guti
currentTurn: 'RED' | 'BLUE'
moveCount: number          - Total moves made (win check starts after 3)
gameEnded: boolean         - Stops all input
gutiShape: 'circle' | 'square' | 'bar'
sliderTargets: NodeKey[]   - Available moves for mobile slider UI
settingsOpen: boolean      - True when settings panel is visible
bgSelectionOpen: boolean   - True when background picker grid is visible
bgImage: Image | null      - Custom/procedural background image (depth -10)
bgThumbs: Image[]          - Background picker thumbnails
bgPickerObjects: GameObject[] - All objects in the bg picker modal (cleanup on close)
colorPickerOpen: boolean   - True when guti color picker is visible
colorPickerObjects: GameObject[] - All objects in the color picker modal (cleanup on close)
currentColorPairIndex: number - Index into COLOR_PAIRS (currently applied pair)
```

## Key Methods (GameScene)
| Method | Purpose |
|--------|---------|
| `addGuti(nodeKey, owner, color)` | Places guti, binds click handler (respects settingsOpen) |
| `tryMove(target)` | One-step move OR eat-adjacent opponent capture; enforces no-overlap |
| `executeMove(from, to, captured?)` | Animates move, records history, switches turn |
| `capture(node)` | Removes opponent guti (state synced immediately) + fade animation |
| `showValidMoves(guti)` | Draws green (move) / orange (capture) hints on adjacent nodes |
| `getAvailableTargets(guti)` | Adjacent empty (move) + adjacent opponent (capture) nodes |
| `checkWin()` | Scans WIN_LINES for all-RED or all-BLUE |
| `gameOver(winner)` | Overlay modal (depth 230+), records stats, Play Again button |
| `undoMove()` | Pops last move, restores position + captured piece + capture counts |
| `applyShapeToAll(shape)` | Destroys all guti sprites, recreates with new shape |
| `applyColorPair(index)` | Recolors both sides' gutis in place from COLOR_PAIRS[index] |
| `openSettings()` / `closeSettings()` | Toggle settings panel visibility |
| `openBackgroundPicker()` / `hideBackgroundPicker()` | Show/close sample grid modal (depth 240+) |
| `setDefaultBackground(id)` | Sets a sample background (depth -10) |
| `uploadBackgroundImage(file)` | FileReader → base64 → Phaser Image at depth -10 |
| `resetBackgroundImage()` | Destroys bg image |

## Depth Layers
```
-10  - Background image (below board lines, which are default depth 0)
1    - Board nodes (dots)
3    - Move hint circles
5    - Guti sprites
6    - Top/bottom bar backgrounds
7-9  - Bar text, gear button
200  - Settings dark overlay
201  - Settings panel box
202-203 - Settings buttons/text
220-222 - Stats overlay
230-233 - Game over overlay
240-243 - Background picker modal
260-263 - Guti color picker modal
```

## Tech Stack
- Phaser 3.90+ (game engine)
- TypeScript 5.9
- Vite 7.3 (bundler)
- Express 4.18 (production server via server.js)
- No external assets (all procedural: shapes, Web Audio beeps)
- DOM: only hidden file input + mobile move slider

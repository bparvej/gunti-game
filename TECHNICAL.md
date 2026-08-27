# Gunti Game - Technical Reference

## Overview
Bengali traditional 2-player board game. Phaser 3 + TypeScript + Vite. 600x600 canvas. **All UI is inside the canvas** (no external DOM overlay). Only a mobile move slider remains as DOM.

## Game Rules
- **Players**: RED and BLUE. Each has **3 gutis (pieces)**.
- **Board**: 9 nodes arranged as a 3x3 grid with center, corners, and edge-midpoints. Nodes connected by lines (horizontal, vertical, diagonal, center-to-all).
- **Turn**: RED goes first. Players alternate.
- **Move**: Select own guti -> click adjacent connected empty node. One step per turn.
- **Capture (jump)**: If opponent's guti sits on a node exactly between your guti and an empty node beyond, you can jump over it to capture. Capture = remove opponent piece.
- **Win**: First player to align all 3 gutis on any of the 8 win lines (3 rows, 3 cols, 2 diagonals) wins. Checked after move 3+.
- **Capture removal**: Opponent's captured guti is destroyed with animation.

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
`getJumpedNode(from, to)`: finds node at midpoint `(from+to)/2`. If midpoint exists in NODES and has opponent piece and destination is empty -> capture.

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
Semi-transparent dark overlay (depth 200) + white panel (depth 201) centered at (300,300).
```
┌──── ⚙ Settings ─── [✕] ────┐
│                              │
│   [THEME: Classic Light]     │
│   [SOUND: ON]                │
│   [STATS]                    │
│   [UNDO]                     │
│   [SHAPE: Circle]            │
│   [🎨 BACKGROUND]  ← opens  │
│        preset grid           │
└──────────────────────────────┘
```
Click dark overlay or ✕ to close. Clicking panel buttons uses `stopPropagation()`.

### Background Picker (🎨 BACKGROUND button)
Opens modal grid (depth 240+) over the settings panel. **5 procedural presets** as thumbnails + upload option. Fully touch-friendly (large tap targets).
```
┌── Choose Background ────────┐
│  [🌿Grass][🪵Wood][☁️Sky]   │
│  [🌙Night  ][🏖️Sand        ] │
│  [ ─────────────────── ]    │
│  [📁 Upload from Device ]   │
└──────────────────────────────┘
```
- Tapping a preset image sets it as the full-canvas background (depth 0).
- "Upload from Device" triggers hidden `<input type="file">`, read as base64 → Phaser Image.
- Overlay tap / ✕ closes the picker. Tracks all objects in `bgPickerObjects[]` for clean destroy.

## Default Backgrounds (BackgroundManager.ts)
5 procedural textures generated at scene start via Phaser Graphics → `generateTexture()`:
| id | label | icon | appearance |
|----|-------|------|-----------|
| green | Grass | 🌿 | green fill + darker stripes |
| wood | Wood | 🪵 | brown fill + vertical planks |
| sky | Sky | ☁️ | blue + white clouds + green ground |
| night | Night | 🌙 | dark + 120 stars + crescent moon |
| sand | Sand | 🏖️ | tan fill + wavy lines + sea strip |
Each stored as `defaultTextureKeys[id]` → texture keys `bg-green`, `bg-wood`, etc.

## Background Image Feature
- **5 presets**: procedural textures (see above), chosen from grid.
- **Upload**: gear → 🎨 BACKGROUND → 📁 Upload from Device → hidden `<input type="file" id="bg-image-input">`.
- File read as base64 DataURL → `textures.addBase64()` → Phaser Image at depth 0 (behind everything).
- **Reset**: Uploading a new BG or picking a preset destroys the current `bgImage` first.
- Persists until scene restart or replaced.

## File Structure
```
src/
  main.ts              - Entry. Creates Phaser.Game with gameConfig.
  config/gameConfig.ts - Phaser config: 600x600, AUTO renderer, FIT scale, GameScene.
  scenes/GameScene.ts  - Core game logic (~720 lines). All game + in-canvas UI.
  board/
    Board.ts           - Draws board lines (outer square + cross + X diagonals).
    Nodes.ts           - 9-node graph with positions and adjacency links.
    WinLines.ts        - 8 winning lines of 3 nodes.
  guti/Guti.ts         - Guti class: sprite (circle/square/bar), nodeKey, owner, moveTo(), captureAnimation().
  managers/
    ThemeManager.ts    - 5 themes (Classic Light, Dark, Ocean Blue, Sunset Gold, Purple Dream). Cycles on button.
    BackgroundManager.ts - Generates 5 procedural background textures (grass, wood, sky, night, sand).
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
bgImage: Image | null      - Custom/procedural background image (depth 0)
bgThumbs: Image[]          - Background picker thumbnails
bgPickerObjects: GameObject[] - All objects in the picker modal (cleanup on close)
```

## Key Methods (GameScene)
| Method | Purpose |
|--------|---------|
| `addGuti(nodeKey, owner, color)` | Places guti, binds click handler (respects settingsOpen) |
| `tryMove(target)` | Validates normal move or capture, executes |
| `executeMove(from, to)` | Animates move, records history, switches turn |
| `capture(node)` | Removes opponent guti with fade animation |
| `getJumpedNode(from, to)` | Returns midpoint node key for jump detection |
| `showValidMoves(guti)` | Draws green/orange hint circles on valid targets |
| `checkWin()` | Scans WIN_LINES for all-RED or all-BLUE |
| `gameOver(winner)` | Overlay modal (depth 230+), records stats, Play Again button |
| `undoMove()` | Pops last move, restores position + captured piece + capture counts |
| `applyShapeToAll(shape)` | Destroys all guti sprites, recreates with new shape |
| `openSettings()` / `closeSettings()` | Toggle settings panel visibility |
| `openBackgroundPicker()` / `hideBackgroundPicker()` | Show/close preset grid modal (depth 240+) |
| `setDefaultBackground(id)` | Sets a procedural preset as background (depth 0) |
| `uploadBackgroundImage(file)` | FileReader → base64 → Phaser Image at depth 0 |
| `resetBackgroundImage()` | Destroys bg image |

## Depth Layers
```
0    - Custom background image
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
```

## Tech Stack
- Phaser 3.90+ (game engine)
- TypeScript 5.9
- Vite 7.3 (bundler)
- Express 4.18 (production server via server.js)
- No external assets (all procedural: shapes, Web Audio beeps)
- DOM: only hidden file input + mobile move slider

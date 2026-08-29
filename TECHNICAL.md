# Gunti Game — Full Technical Reference

A complete guide for both **humans** and **AI agents** to understand, run, modify, and replicate this project.

---

## 1. Overview

Bengali traditional 2-player board game ("Guti"). Built with **Phaser 3 + TypeScript + Vite**. Runs in the browser on a **600×600 canvas**. **All UI lives inside the canvas** — there is no external DOM control panel. The only DOM elements are a hidden file input (for background upload) and a mobile move slider.

Live demo: https://gunti-game.onrender.com

---

## 2. Quick Start

```bash
# Prerequisites: Node.js 20.19+ (Vite 7 requirement)
cd gunti-game
npm install
npm run dev          # dev server -> http://localhost:5173
npm run build        # production build (dist/)
npm run preview      # preview the production build
```

**Production hosting** (`render.yaml`, `server.js`): a minimal Express static server serves the built `dist/` folder. `server.js`:
```js
const express = require('express');
const path = require('path');
const app = express();
app.use(express.static(path.join(__dirname, 'dist')));
// fallback to index.html for SPA routing
app.get('*', (req, res) => res.sendFile(path.join(__dirname, 'dist', 'index.html')));
app.listen(process.env.PORT || 3000);
```

---

## 3. Game Rules (as implemented)

- **Players**: two sides (default RED vs BLUE, colors changeable via the color picker). Each side has **3 gutis**.
- **Turn**: Player 1 (RED side) moves first; players alternate.
- **Move**: tap your guti to select it, then tap an **adjacent connected** empty node.
  - **One step only** — a guti moves exactly one node per turn. No multi-node jumps.
- **Capture (eat)**: if your guti is adjacent to an **opponent's** guti, tap the opponent's guti → it is **eaten** (removed) and your guti moves into its node. Eating still counts as one step.
- **No overlap**: a guti can never land on a node occupied by your own piece — such taps are ignored.
- **Win**: align **all 3 of your gutis** on any win line (3 rows, 3 columns, 2 diagonals). Win is checked once `moveCount > 3`.
- **Capture removal**: the eaten guti is removed from board state immediately, then a fade animation destroys its sprite.

---

## 4. Board Topology (`src/board/Nodes.ts`)

9 nodes on a 600×600 grid, coordinates and adjacency:

```
TL(100,100) ------ T(300,100) ------ TR(500,100)
   |     \          |          /       |
   |       \        |        /         |
L(100,300) ----- C(300,300) ----- R(500,300)
   |       /        |        \         |
   |     /          |          \       |
BL(100,500) ------ B(300,500) ------ BR(500,500)
```

- **NodeKey** = `T | B | L | R | TL | TR | BL | BR | C`
- Each node has `links: NodeKey[]` = valid adjacent destinations.
- Center `C` links to **all 8** other nodes.
- Edge nodes (`T,B,L,R`) link to center + 2 corner neighbors.
- Corner nodes link to center + 2 edge neighbors.

### Win Lines (`src/board/WinLines.ts`)
8 lines of 3 collinear nodes:
```
Rows:    [TL,T,TR], [L,C,R], [BL,B,BR]
Columns: [TL,L,BL], [T,C,B], [TR,R,BR]
Diags:   [TL,C,BR], [TR,C,BL]
```

---

## 5. Core Game Flow / Data Model

### Key state (in `GameScene`)
| Field | Type | Purpose |
|-------|------|---------|
| `gutis` | `Guti[]` | All pieces currently on the board |
| `selectedGuti` | `Guti \| null` | The piece the current player selected |
| `occupied` | `Record<NodeKey, Guti>` | Maps each node to the piece on it (the source of truth) |
| `currentTurn` | `'RED' \| 'BLUE'` | Whose turn it is |
| `moveCount` | `number` | Total moves; used to gate win checking |
| `gameEnded` | `boolean` | True after a winner is declared (blocks input) |
| `gutiShape` | `'circle' \| 'square' \| 'bar'` | Sprite render shape |
| `redCaptured` / `blueCaptured` | `number` | Pieces each side has lost |
| `settingsOpen` / `bgSelectionOpen` / `colorPickerOpen` | `boolean` | Modal visibility flags |
| `bgImage` | `Image \| null` | Current background image (depth -10) |

### Move resolution (`tryMove`)
```ts
tryMove(target): void {
  if (!gameEnded && selectedGuti) {
    const from = selectedGuti.nodeKey;
    if (NODES[from].links.includes(target)) {   // ONE STEP only
      const occupant = occupied[target];
      if (!occupant)                 executeMove(from, target);            // move
      else if (opponent) { capture(target); executeMove(from, target, target); } // eat
      // own piece -> blocked (no overlap)
    }
  }
}
```

### Capture (`capture`)
- Increments the opponent's captured count.
- **Removes the piece from `occupied` and `gutis` synchronously** (critical — this lets the capturing guti move in).
- Only the sprite fade/destroy is async (via `captureAnimation`). **Do not** mutate `occupied` inside the async callback (that was a past bug where it erased the capturing guti).

### Undo (`undoMove`)
- Pops the last `Move` from `MoveHistoryManager`.
- Moves the guti back from `to` → `from`.
- If a piece was captured (recorded as `captured` node), **re-creates** it at that node and decrements the capture count.
- Restores `currentTurn` to the mover.

---

## 6. In-Canvas UI Layout (600×600)

```
┌──────────────────────────────────────────┐
│ [🔴 RED's Turn]                    [⚙]  │  Top bar y=18 + Gear (575,18)
│                                          │
│  TL ──── T ──── TR                       │
│   │ ╲    │    ╱ │                        │
│  L ──── C ──── R      Game board         │
│   │ ╱    │    ╲ │     (100-500)          │
│  BL ──── B ──── BR                       │
│                                          │
│ [Shape: ●]              [Tap a RED guti] │  Bottom bar y=582
└──────────────────────────────────────────┘
```

### Settings Panel (gear ⚙) — depth 200–203
White box 300×480 centered at (300,300). 8 buttons (45px apart), each calls `makePanelBtn`:

| Y | Button | Action |
|---|--------|--------|
| 170 | THEME | cycle 5 themes (restarts scene) |
| 215 | SOUND | toggle on/off (Web Audio) |
| 260 | STATS | show persistent stats overlay |
| 305 | UNDO | undo last move |
| 350 | SHAPE | cycle circle / square / bar |
| 395 | 🎨 GUTI COLOR | open color-pair picker |
| 440 | 🎨 BACKGROUND | open background picker |
| 490 | ❓ HOW TO PLAY | show rules overlay |

Panel buttons use `pointerdown` + `stopPropagation()` so they don't trigger the dark-overlay close.

### HOW TO PLAY (❓) — depth 280+
Overlay modal listing the rules: selection, green move dots, orange eat dots, one-step rule, no-overlap, win condition, and the settings tip.

### Guti Color Pair Picker (🎨 GUTI COLOR) — depth 260+
6 predefined pairs from static `GameScene.COLOR_PAIRS`, shown as two-dot swatches. Tapping calls `applyColorPair(i)` which recolors **existing** guti sprites in place (`g.sprite.setFillStyle(color)`) preserving nodeKey/owner.

```
Red vs Blue · Green vs Orange · Pink vs Teal
Yellow vs Purple · White vs Black · Brown vs Cyan
```

### Background Picker (🎨 BACKGROUND) — depth 240+
6 sample thumbnails (3×2 grid) + "📁 Upload from Device". Tapping a sample calls `setDefaultBackground(id)`; upload reads a file → base64 → Phaser Image.

---

## 7. Backgrounds (`src/managers/BackgroundManager.ts`)

6 fully **procedural** sample backgrounds generated to textures at runtime (no image files — works offline). Generated once in `create()` via `ensureGenerated()` using Phaser `Graphics` + `generateTexture()`.

| id | label | icon | appearance |
|----|-------|------|-----------|
| `teakwood` | Teak Wood | 🪵 | wood + grain + carved corners |
| `velvet` | Velvet Red | 🔴 | red cloth + gold border |
| `greenmat` | Green Mat | 🌿 | jute mat weave + leaves |
| `night` | Moonlit Night | 🌙 | stars + moon + hills |
| `marble` | Marble | 🪨 | marble veins + patches |
| `dino` | Funny Dino | 🦖 | cartoon T-Rex scene |

Texture keys: `bg-teakwood`, `bg-velvet`, `bg-greenmat`, `bg-night`, `bg-marble`, `bg-dino`.
Stored in `defaultTextureKeys[id]`; exposed via `getDefaultTextureKey(id)`.

### User-uploaded background
- Hidden `<input type="file" id="bg-image-input" accept="image/*">` in `index.html`.
- File read as base64 DataURL → `this.textures.addBase64(key, dataUrl)`.
- **IMPORTANT**: `addBase64` loads async. Listen for the `'addtexture'` **ADD event on the TextureManager** (NOT `'addtexture-<key>'`), and check `textures.exists(key)` as a fallback after 50ms.
- Background rendered as `Image(300,300)` at **depth -10** (behind the board).
- Replacing/resetting destroys the old `bgImage` first.

---

## 8. Managers

| Class | File | Responsibility |
|-------|------|----------------|
| `ThemeManager` | `managers/ThemeManager.ts` | 5 color themes, cycle/next, per-theme colors/hints |
| `BackgroundManager` | `managers/BackgroundManager.ts` | 6 procedural sample textures |
| `SoundManager` | `managers/SoundManager.ts` | Web Audio beeps (no files): move, capture, win, slide-whoosh, yoo |
| `StatsManager` | `managers/StatsManager.ts` | localStorage persistence: redWins, blueWins, totalGames, averageMoves |
| `MoveHistoryManager` | `managers/MoveHistoryManager.ts` | Move stack for undo: `{player, from, to, captured}` |

---

## 9. File Structure

```
gunti-game/
├── index.html              # single HTML shell; hidden file input; mobile slider
├── package.json            # scripts: dev/build/preview; deps: phaser, express
├── tsconfig.json           # TypeScript config
├── render.yaml             # Render.com deploy config
├── server.js               # Express static server for production
├── .github/workflows/      # CI
└── src/
    ├── main.ts                 # creates Phaser.Game(gameConfig)
    ├── config/gameConfig.ts    # Phaser config: 600x600, AUTO, FIT scale
    ├── scenes/GameScene.ts     # ALL game logic + in-canvas UI (~1000 lines)
    ├── board/
    │   ├── Board.ts            # draws board lines
    │   ├── Nodes.ts            # 9-node graph + adjacency
    │   └── WinLines.ts         # 8 winning lines
    ├── guti/Guti.ts            # piece sprite + moveTo + captureAnimation
    └── managers/
        ├── ThemeManager.ts
        ├── BackgroundManager.ts
        ├── SoundManager.ts
        ├── StatsManager.ts
        └── MoveHistoryManager.ts
```

---

## 10. Depth Layers (z-order in canvas)

```
-10   Background image
 1    Board node dots
 3    Move hint circles
 5    Guti sprites
 6    Top/bottom bar backgrounds
 7-9  Bar text / gear button
 200  Settings dark overlay
 201  Settings panel box
 202-203 Settings buttons/text
 220-222 Stats overlay
 230-233 Game over overlay
 240-243 Background picker modal
 260-263 Guti color picker modal
 280-283 How to Play modal
```

---

## 11. Key Methods (GameScene)

| Method | Purpose |
|--------|---------|
| `create()` | Init managers, build board/nodes/gutis/UI, generate backgrounds |
| `addGuti(nodeKey, owner, color)` | Place a piece; own=select, adjacent opponent=eat |
| `tryMove(target)` | One-step move OR capture; enforces no-overlap |
| `executeMove(from, to, captured?)` | Animate, update `occupied`, record history, switch turn |
| `capture(node)` | Remove opponent (state synced immediately) + fade |
| `showValidMoves(guti)` | Green hints for moves, orange for adjacent enemies |
| `getAvailableTargets(guti)` | For mobile slider + bottom-bar hint |
| `checkWin()` / `gameOver(winner)` | Detect / display winner modal + save stats |
| `undoMove()` | Undo last move, restore captured piece |
| `applyShapeToAll(shape)` | Recreate all sprites with new shape |
| `applyColorPair(index)` | Recolor both sides in place |
| `showHowToPlay()` | Show rules overlay |
| `uploadBackgroundImage(file)` | Handle user image upload |
| `setDefaultBackground(id)` / `resetBackgroundImage()` | Set/clear background |

---

## 12. Interaction & Mobile

- **Touch/click**: all interactive objects call `.setInteractive()` and listen for `pointerdown`.
- **Mobile move slider**: on selecting a guti, a DOM range slider (`#move-slider-wrap`) appears letting mobile users pick a target, with MOVE/CANCEL buttons.
- Canvas uses `touch-action: none` / `manipulation` and `-webkit-tap-highlight-color: transparent`.
- Viewport meta sets `user-scalable=no`, `maximum-scale=1.0` to prevent double-tap zoom.

---

## 13. Conventions & Notes for Future Agents

- **Single source of truth for positions**: `this.occupied` map — always update it in sync with `this.gutis`.
- **Never mutate game state inside async callbacks** (tweens/`delayedCall`) unless intended — it caused capture bugs.
- **Depth values matter** — keep modals above `200`, game pieces at `5`, background negative.
- **All UI is in-canvas** — preferences (theme, colors, shape, background) are **not** persisted across reloads; only stats persist (localStorage).
- **Node coordinates are absolute** (100–500) and baked into `Nodes.ts`; the board is centered at (300,300).
- Sound uses the **Web Audio API** directly (no asset files). Sound must be created in response to a user gesture (browser autoplay policy).

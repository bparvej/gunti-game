# 🎲 Gunti Game (Bengali Traditional Board Game)

A modern, mobile-friendly implementation of the classic Bengali **Guti** board game built with **Phaser 3**, **TypeScript**, and **Vite**.

🔗 **Live demo:** https://gunti-game.onrender.com

---

## 🕹️ How to Play

- **2 players**, 3 pieces each. Player 1 (RED) moves first.
- **Move:** tap one of your gutis, then tap an adjacent empty dot.
  - 🟢 green dots = legal moves (one step only)
- **No capturing:** gutis can never eat or remove each other — you can only move onto empty dots.
- **Win:** get all 3 of your gutis in a straight row, column, or diagonal.

> In-game, open **⚙ Settings → ❓ How to Play** for the full rules.

---

## ✨ Features

- 🟥🟦 **Custom guti colors** — pick from 6 color pairs
- 🎨 **6 sample backgrounds** (wood, velvet, mat, night, marble, funny dinosaur)
- 📁 **Upload your own background** from your device
- 🌗 **5 color themes** (Classic, Dark, Ocean, Sunset, Purple)
- 🅾️ **Piece shapes** — circle, square, bar (ঝাড়ুর কাঠি)
- 🔄 **Undo** moves
- 🔊 **Sound effects** (pure Web Audio, no files)
- 📊 **Persistent stats** (wins, average moves)
- 📱 **Fully touch/mobile-friendly**

---

## 🚀 Run Locally

```bash
# Node.js 20.19+ required (Vite 7)
npm install
npm run dev      # http://localhost:5173
```

Build for production:
```bash
npm run build    # outputs to dist/
npm run preview  # serve the built version
```

---

## 🗂️ Project Structure

```
src/
├── main.ts                  # Phaser game entry
├── config/gameConfig.ts     # Phaser config
├── scenes/GameScene.ts      # All game logic + UI
├── board/                   # Board, nodes, win lines
├── guti/Guti.ts             # Piece class
└── managers/                # Theme, Background, Sound, Stats, MoveHistory
```

---

## 🧠 For Developers / AI Agents

A comprehensive technical reference is in **[TECHNICAL.md](TECHNICAL.md)** — it documents the game rules, board topology, win lines, capture flow, UI layout, depth layers, managers, file structure, and replication notes.

---

## ☁️ Hosting

- **Render.com:** `render.yaml` + `server.js` (Express serves the built `dist/`).
- **CI:** `.github/workflows/` builds and checks the project.

---

## 📜 License

ISC

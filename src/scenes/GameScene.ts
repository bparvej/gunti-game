import Phaser from 'phaser';
import { Board } from '../board/Board';
import { NODES, NodeKey } from '../board/Nodes';
import { Guti, Player } from '../guti/Guti';
import { WIN_LINES } from '../board/WinLines';
import { SoundManager } from '../managers/SoundManager';
import { ThemeManager } from '../managers/ThemeManager';
import { StatsManager } from '../managers/StatsManager';
import { MoveHistoryManager, Move } from '../managers/MoveHistoryManager';
import { themeManager } from '../config/gameConfig';

export class GameScene extends Phaser.Scene {
  gutis: Guti[] = [];
  selectedGuti: Guti | null = null;

  occupied: Partial<Record<NodeKey, Guti>> = {};

  currentTurn: Player = 'RED';
  moveHints: Phaser.GameObjects.Circle[] = [];
  moveCount: number = 0;

  // Managers
  soundManager!: SoundManager;
  themeManager!: ThemeManager;
  statsManager!: StatsManager;
  moveHistoryManager!: MoveHistoryManager;

  // UI Elements
  turnText!: Phaser.GameObjects.Text;
  redScoreText!: Phaser.GameObjects.Text;
  blueScoreText!: Phaser.GameObjects.Text;
  themeButtonText!: Phaser.GameObjects.Text;
  soundButtonText!: Phaser.GameObjects.Text;
  statsButtonText!: Phaser.GameObjects.Text;
  undoButtonText!: Phaser.GameObjects.Text;

  redCaptured: number = 0;
  blueCaptured: number = 0;
  gutiShape: 'circle' | 'square' | 'bar' = 'circle';
  gameEnded: boolean = false;

  sliderTargets: NodeKey[] = [];
  constructor() {
    super('GameScene');
  }

  create(): void {
    // Initialize managers
    this.soundManager = new SoundManager(this);
    this.themeManager = themeManager;
    this.statsManager = new StatsManager();
    this.moveHistoryManager = new MoveHistoryManager();

    const theme = this.themeManager.getCurrentTheme();

    // Set background color
    this.cameras.main.setBackgroundColor(theme.backgroundColor);

    // Draw board
    new Board(this, theme.boardLineColor);

    // Draw nodes
    Object.entries(NODES).forEach(([key, n]) => {
      const dot = this.add.circle(n.x, n.y, 8, theme.boardLineColor);
      dot.setInteractive();

      dot.on('pointerdown', () => {
        this.hideMoveSlider();
        this.tryMove(key as NodeKey);
      });
    });

    // ---- GUTI SETUP ----
    this.addGuti('T', 'RED', theme.redColor);
    this.addGuti('TL', 'RED', theme.redColor);
    this.addGuti('TR', 'RED', theme.redColor);

    this.addGuti('B', 'BLUE', theme.blueColor);
    this.addGuti('BL', 'BLUE', theme.blueColor);
    this.addGuti('BR', 'BLUE', theme.blueColor);

    // Expose scene to DOM controls
    (window as any).gameScene = this;

    // UI Setup (DOM)
    this.bindDOMUI(theme);
  }
  bindDOMUI(theme: any): void {
    // Set simple Phaser text for backward compatibility and internal updates
    this.turnText = this.add.text(20, 20, 'Turn: RED', { fontSize: '18px', color: theme.textColor }).setDepth(5);

    // Hook DOM elements
    const btnTheme = document.getElementById('btn-theme');
    const btnSound = document.getElementById('btn-sound');
    const btnStats = document.getElementById('btn-stats');
    const btnUndo = document.getElementById('btn-undo');
    const uiTurn = document.getElementById('ui-turn');
    const uiRed = document.getElementById('ui-red');
    const uiBlue = document.getElementById('ui-blue');
    const selectShape = document.getElementById('guti-shape') as HTMLSelectElement | null;

    if (btnTheme) {
      btnTheme.addEventListener('click', () => this.changeTheme());
      btnTheme.innerText = `THEME: ${theme.name}`;
    }
    if (btnSound) btnSound.addEventListener('click', () => this.toggleSound());
    if (btnStats) btnStats.addEventListener('click', () => this.showStats());
    if (btnUndo) btnUndo.addEventListener('click', () => this.undoMove());
    if (selectShape) {
      selectShape.value = this.gutiShape;
      selectShape.addEventListener('change', (e) => {
        const newShape = (e.target as HTMLSelectElement).value as 'circle' | 'square' | 'bar';
        this.gutiShape = newShape;
        // Immediately apply new shape to all existing gutis
        this.applyShapeToAll(newShape);
      });
    }

    // Hook move slider and buttons
    const moveSlider = document.getElementById('move-slider') as HTMLInputElement | null;
    const btnMove = document.getElementById('btn-move');
    const btnCancelMove = document.getElementById('btn-cancel-move');
    const sliderLabel = document.getElementById('slider-label');

    if (moveSlider) {
      moveSlider.addEventListener('input', () => {
        const idx = parseInt(moveSlider.value, 10) || 0;
        const target = this.sliderTargets[idx];
        if (sliderLabel && target) sliderLabel.innerText = `Move to ${target}`;
        // highlight selected slider target
        this.clearHints();
        if (target) this.drawHint(target, this.themeManager.getCurrentTheme().hintNormalColor);
      });
    }

    if (btnMove) btnMove.addEventListener('click', () => {
      if (!this.selectedGuti) return;
      const moveIdx = moveSlider ? parseInt(moveSlider.value, 10) || 0 : 0;
      const targetNode = this.sliderTargets[moveIdx];
      if (targetNode) {
        this.tryMove(targetNode);
      }
      this.hideMoveSlider();
    });

    if (btnCancelMove) btnCancelMove.addEventListener('click', () => {
      this.hideMoveSlider();
    });

    // store DOM refs for updates
    (this as any)._ui = { uiTurn, uiRed, uiBlue };
    // initial DOM update
    if (uiTurn) uiTurn.innerText = `Turn: ${this.currentTurn}`;
    if (uiRed) uiRed.innerText = `Red Captured: ${this.redCaptured}`;
    if (uiBlue) uiBlue.innerText = `Blue Captured: ${this.blueCaptured}`;
    this.updateSoundButtonText();
  }

  applyShapeToAll(shape: 'circle' | 'square' | 'bar'): void {
    // Replace all guti sprites with the new shape while preserving owner/nodeKey/color
    const oldGutis = [...this.gutis];
    const newGutis: Guti[] = [];
    const newOccupied: Partial<Record<NodeKey, Guti>> = {};

    oldGutis.forEach(old => {
      const nodeKey = old.nodeKey;
      const owner = old.owner;
      const color = (old as any).color ?? (owner === 'RED' ? this.themeManager.getCurrentTheme().redColor : this.themeManager.getCurrentTheme().blueColor);

      // destroy old sprite
      try { old.sprite.destroy(); } catch (e) { /* ignore */ }

      const ng = new Guti(this, nodeKey, owner, color, shape);
      newGutis.push(ng);
      newOccupied[nodeKey] = ng;

      ng.sprite.on('pointerdown', () => {
        if (this.gameEnded) return;
        if (ng.owner !== this.currentTurn) return;
        this.clearHints();
        this.selectedGuti = ng;
        this.highlightSelection(ng);
        this.showValidMoves(ng);
      });
    });

    this.gutis = newGutis;
    this.occupied = newOccupied;

    // If a piece was selected, re-select the corresponding new guti
    if (this.selectedGuti) {
      const node = this.selectedGuti.nodeKey;
      this.selectedGuti = this.occupied[node] || null;
    }
  }

  createButton(x: number, y: number, width: number, height: number, text: string, onClick: () => void): void {
    const button = this.add.rectangle(x + width / 2, y + height / 2, width, height, 0x888888);
    button.setInteractive();
    button.on('pointerdown', onClick);

    const buttonText = this.add.text(x + width / 2, y + height / 2, text, {
      fontSize: '12px',
      color: '#ffffff',
    }).setOrigin(0.5);
  }

  changeTheme(): void {
    const newTheme = this.themeManager.nextTheme();
    this.soundManager.playMoveSound();

    // Update background
    this.cameras.main.setBackgroundColor(newTheme.backgroundColor);

    // Update all elements
    const btnTheme = document.getElementById('btn-theme');
    if (btnTheme) btnTheme.innerText = `THEME: ${newTheme.name}`;
    this.refreshTheme(newTheme);
  }

  refreshTheme(theme: any): void {
    // Restart scene with new theme
    this.scene.restart();
  }

  toggleSound(): void {
    this.soundManager.toggleSound();
    this.updateSoundButtonText();
  }

  updateSoundButtonText(): void {
    const status = this.soundManager.isSoundEnabled() ? 'ON' : 'OFF';
    const btn = document.getElementById('btn-sound');
    if (btn) btn.innerText = `SOUND: ${status}`;
  }

  showStats(): void {
    const stats = this.statsManager.getStats();
    const statsText = `STATS
Red Wins: ${stats.redWins}
Blue Wins: ${stats.blueWins}
Total Games: ${stats.totalGames}
Avg Moves: ${stats.averageMoves}`;

    const displayText = this.add.text(300, 200, statsText, {
      fontSize: '16px',
      color: '#000000',
      align: 'center',
      backgroundColor: '#ffffff',
      padding: { x: 20, y: 20 },
    }).setOrigin(0.5).setDepth(100);

    this.time.delayedCall(3000, () => {
      displayText.destroy();
    });
  }

  undoMove(): void {
    if (this.moveHistoryManager.getMoveCount() < 1) {
      return;
    }

    const lastMove = this.moveHistoryManager.undoLastMove();
    if (!lastMove) return;

    this.soundManager.playMoveSound();

    // Find the guti that moved
    const guti = this.occupied[lastMove.to];
    if (guti) {
      guti.moveTo(lastMove.from, true);
      delete this.occupied[lastMove.to];
      this.occupied[lastMove.from] = guti;
    }

    // Restore captured piece if any
    if (lastMove.captured) {
      const capturedGuti = new Guti(
        this,
        lastMove.captured,
        lastMove.player === 'RED' ? 'BLUE' : 'RED',
        lastMove.player === 'RED' ? 0x0000ff : 0xff0000,
        this.gutiShape
      );
      this.occupied[lastMove.captured] = capturedGuti;
      this.gutis.push(capturedGuti);
    }

    this.moveCount--;
    this.currentTurn = lastMove.player;
    this.updateTurnDisplay();
  }

  /* ---------------- GUTI ---------------- */

  addGuti(nodeKey: NodeKey, owner: Player, color: number): void {
    const guti = new Guti(this, nodeKey, owner, color, this.gutiShape);

    this.occupied[nodeKey] = guti;
    this.gutis.push(guti);

    guti.sprite.on('pointerdown', () => {
      if (this.gameEnded) return;
      if (guti.owner !== this.currentTurn) return;

      this.clearHints();
      this.selectedGuti = guti;
      this.highlightSelection(guti);
      this.showValidMoves(guti);
      // Show mobile slider targets
      this.showMoveSliderFor(guti);
    });
  }

  /* ---------------- MOVEMENT ---------------- */

  tryMove(target: NodeKey): void {
    if (this.gameEnded) return;
    if (!this.selectedGuti) return;

    const from = this.selectedGuti.nodeKey;

    // Normal move
    if (
      NODES[from].links.includes(target) &&
      !this.occupied[target]
    ) {
      this.executeMove(from, target);
      return;
    }

    // Capture move
    const jumped = this.getJumpedNode(from, target);
    if (
      jumped &&
      this.occupied[jumped] &&
      this.occupied[jumped]?.owner !== this.currentTurn &&
      !this.occupied[target]
    ) {
      this.capture(jumped);
      this.executeMove(from, target);
      this.soundManager.playCaptureSound();
    }
  }

  executeMove(from: NodeKey, to: NodeKey): void {
    this.selectedGuti!.moveTo(to, true, 300);
    delete this.occupied[from];
    this.occupied[to] = this.selectedGuti!;

    // Record move
    const jumped = this.getJumpedNode(from, to);
    this.moveHistoryManager.recordMove(this.currentTurn, from, to, jumped);

    this.soundManager.playSlideSound();
    this.clearHints();
    this.clearSelection();

    this.moveCount++;

    if (this.moveCount > 3) {
      this.checkWin();
    }

    this.switchTurn();
  }

  /* ---------------- CAPTURE ---------------- */

  getJumpedNode(from: NodeKey, to: NodeKey): NodeKey | null {
    const fx = NODES[from].x;
    const fy = NODES[from].y;
    const tx = NODES[to].x;
    const ty = NODES[to].y;

    for (const key in NODES) {
      const n = NODES[key as NodeKey];
      if (
        n.x === (fx + tx) / 2 &&
        n.y === (fy + ty) / 2
      ) {
        return key as NodeKey;
      }
    }
    return null;
  }

  capture(node: NodeKey): void {
    const guti = this.occupied[node];
    if (!guti) return;

    if (guti.owner === 'RED') {
      this.blueCaptured++;
    } else {
      this.redCaptured++;
    }

    guti.captureAnimation(() => {
      guti.sprite.destroy();
      this.gutis = this.gutis.filter(g => g !== guti);
      delete this.occupied[node];
    });

    this.updateScoreDisplay();
  }

  /* ---------------- HIGHLIGHT ---------------- */

  showValidMoves(guti: Guti): void {
    const from = guti.nodeKey;

    NODES[from].links.forEach(n => {
      if (!this.occupied[n]) {
        this.drawHint(n, this.themeManager.getCurrentTheme().hintNormalColor);
      }
    });

    // Capture hints
    Object.keys(NODES).forEach(t => {
      const target = t as NodeKey;
      const jumped = this.getJumpedNode(from, target);

      if (
        jumped &&
        this.occupied[jumped] &&
        this.occupied[jumped]?.owner !== guti.owner &&
        !this.occupied[target]
      ) {
        this.drawHint(target, this.themeManager.getCurrentTheme().hintCaptureColor);
      }
    });
  }

  getAvailableTargets(guti: Guti): NodeKey[] {
    const from = guti.nodeKey;
    const targets: NodeKey[] = [];

    // normal moves
    NODES[from].links.forEach(n => {
      if (!this.occupied[n]) targets.push(n);
    });

    // capture targets
    Object.keys(NODES).forEach(t => {
      const target = t as NodeKey;
      const jumped = this.getJumpedNode(from, target);
      if (
        jumped &&
        this.occupied[jumped] &&
        this.occupied[jumped]?.owner !== guti.owner &&
        !this.occupied[target]
      ) {
        // avoid duplicates
        if (!targets.includes(target)) targets.push(target);
      }
    });

    return targets;
  }

  showMoveSliderFor(guti: Guti): void {
    const sliderDiv = document.getElementById('ui-slider');
    const moveSlider = document.getElementById('move-slider') as HTMLInputElement | null;
    const sliderLabel = document.getElementById('slider-label');
    if (!sliderDiv || !moveSlider || !sliderLabel) return;

    const targets = this.getAvailableTargets(guti);
    this.sliderTargets = targets;
    if (targets.length === 0) {
      sliderDiv.style.display = 'none';
      return;
    }

    moveSlider.min = '0';
    moveSlider.max = `${Math.max(0, targets.length - 1)}`;
    moveSlider.value = '0';
    sliderLabel.innerText = `Move to ${targets[0]}`;
    sliderDiv.style.display = 'block';

    // highlight first option
    this.clearHints();
    this.drawHint(targets[0], this.themeManager.getCurrentTheme().hintNormalColor);
  }

  hideMoveSlider(): void {
    const sliderDiv = document.getElementById('ui-slider');
    if (sliderDiv) sliderDiv.style.display = 'none';
    this.sliderTargets = [];
    this.clearHints();
  }

  drawHint(node: NodeKey, color: number): void {
    const n = NODES[node];
    const c = this.add.circle(n.x, n.y, 12, color, 0.4);
    this.moveHints.push(c);
  }

  clearHints(): void {
    this.moveHints.forEach(h => h.destroy());
    this.moveHints = [];
  }

  /* ---------------- TURN ---------------- */

  switchTurn(): void {
    this.currentTurn = this.currentTurn === 'RED' ? 'BLUE' : 'RED';
    this.updateTurnDisplay();
  }

  updateTurnDisplay(): void {
    this.turnText.setText(`Turn: ${this.currentTurn}`);
    const uiTurn = (this as any)._ui?.uiTurn as HTMLElement | null;
    if (uiTurn) uiTurn.innerText = `Turn: ${this.currentTurn}`;
  }

  updateScoreDisplay(): void {
    this.redScoreText && this.redScoreText.setText && this.redScoreText.setText(`Red Captured: ${this.blueCaptured}`);
    this.blueScoreText && this.blueScoreText.setText && this.blueScoreText.setText(`Blue Captured: ${this.redCaptured}`);
    const uiRed = (this as any)._ui?.uiRed as HTMLElement | null;
    const uiBlue = (this as any)._ui?.uiBlue as HTMLElement | null;
    if (uiRed) uiRed.innerText = `Red Captured: ${this.blueCaptured}`;
    if (uiBlue) uiBlue.innerText = `Blue Captured: ${this.redCaptured}`;
  }

  /* ---------------- WIN CHECK ---------------- */

  checkWin(): void {
    for (const line of WIN_LINES) {
      const owners = line.map(n => this.occupied[n]?.owner);
      if (owners.every(o => o === 'RED')) {
        this.gameOver('RED');
        return;
      }
      if (owners.every(o => o === 'BLUE')) {
        this.gameOver('BLUE');
        return;
      }
    }
  }

  gameOver(winner: Player): void {
    this.soundManager.playYooSound();
    this.statsManager.recordWin(winner, this.moveCount);

    const theme = this.themeManager.getCurrentTheme();

    // Semi-transparent overlay
    const overlay = this.add.rectangle(300, 300, 600, 600, 0x000000, 0.7);
    overlay.setDepth(90);

    // Modal background
    const modal = this.add.rectangle(300, 300, 400, 300, 0xffffff);
    modal.setDepth(95);

    // Crown emoji (simple crown) and Winner text
    this.add.text(300, 220, '👑', { fontSize: '40px' }).setOrigin(0.5).setDepth(100);
    this.add.text(300, 250, `${winner} WINS!`, {
      fontSize: '40px',
      color: winner === 'RED' ? '#ff0000' : '#0000ff',
      fontStyle: 'bold',
    }).setOrigin(0.5).setDepth(100);

    // Congratulatory message
    this.add.text(300, 285, `অভিনন্দন! ${winner} জয়লাভ করেছে`, {
      fontSize: '16px',
      color: '#333333',
    }).setOrigin(0.5).setDepth(100);

    // Game info
    this.add.text(300, 310, `Moves: ${this.moveCount}`, {
      fontSize: '16px',
      color: '#000000',
    }).setOrigin(0.5).setDepth(100);

    // Restart button
    const restartBtn = this.add.rectangle(300, 370, 150, 40, 0x4CAF50);
    restartBtn.setInteractive();
    restartBtn.setDepth(100);
    restartBtn.on('pointerdown', () => {
      this.scene.restart();
    });

    this.add.text(300, 370, 'Play Again', {
      fontSize: '18px',
      color: '#ffffff',
      fontStyle: 'bold',
    }).setOrigin(0.5).setDepth(101);

    // mark ended (do not disable input globally so restart button remains interactive)
    this.gameEnded = true;
  }

  /* ---------------- UI ---------------- */

  highlightSelection(guti: Guti): void {
    this.gutis.forEach(g => g.sprite.setStrokeStyle());
    guti.sprite.setStrokeStyle(3, 0x00aa00);
  }

  clearSelection(): void {
    this.selectedGuti = null;
    this.gutis.forEach(g => g.sprite.setStrokeStyle());
  }
}

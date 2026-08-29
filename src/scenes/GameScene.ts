import Phaser from 'phaser';
import { Board } from '../board/Board';
import { NODES, NodeKey } from '../board/Nodes';
import { Guti, Player } from '../guti/Guti';
import { WIN_LINES } from '../board/WinLines';
import { SoundManager } from '../managers/SoundManager';
import { ThemeManager } from '../managers/ThemeManager';
import { StatsManager } from '../managers/StatsManager';
import { MoveHistoryManager } from '../managers/MoveHistoryManager';
import { BackgroundManager, BACKGROUND_OPTIONS } from '../managers/BackgroundManager';
import { themeManager } from '../config/gameConfig';

export class GameScene extends Phaser.Scene {
  // ── Game State ──
  gutis: Guti[] = [];
  selectedGuti: Guti | null = null;
  occupied: Partial<Record<NodeKey, Guti>> = {};
  currentTurn: Player = 'RED';
  moveHints: Phaser.GameObjects.Arc[] = [];
  moveCount = 0;
  gameEnded = false;
  gutiShape: 'circle' | 'square' | 'bar' = 'circle';
  sliderTargets: NodeKey[] = [];
  currentColorPairIndex = 0;
  colorPickerOpen = false;
  colorPickerObjects: Phaser.GameObjects.GameObject[] = [];

  // ── Managers ──
  soundManager!: SoundManager;
  themeManager!: ThemeManager;
  statsManager!: StatsManager;
  moveHistoryManager!: MoveHistoryManager;
  backgroundManager!: BackgroundManager;

  // ── UI Refs (Phaser objects) ──
  turnText!: Phaser.GameObjects.Text;
  gearText!: Phaser.GameObjects.Text;
  bgThumbs: Phaser.GameObjects.Image[] = [];
  bgPickerObjects: Phaser.GameObjects.GameObject[] = [];
  bgSelectionOpen = false;

  // ── Settings Panel ──
  settingsPanel!: Phaser.GameObjects.Group;
  darkOverlay!: Phaser.GameObjects.Rectangle;
  settingsOpen = false;
  bgImage: Phaser.GameObjects.Image | null = null;

  constructor() {
    super('GameScene');
  }

  create(): void {
    this.soundManager = new SoundManager(this);
    this.themeManager = themeManager;
    this.statsManager = new StatsManager();
    this.moveHistoryManager = new MoveHistoryManager();
    this.backgroundManager = new BackgroundManager(this);
    this.backgroundManager.ensureGenerated();

    const theme = this.themeManager.getCurrentTheme();
    this.cameras.main.setBackgroundColor(theme.backgroundColor);

    // ── Board & Nodes ──
    new Board(this, theme.boardLineColor);
    this.drawNodes(theme);

    // ── Gutis (3 each) ──
    this.addGuti('T', 'RED', theme.redColor);
    this.addGuti('TL', 'RED', theme.redColor);
    this.addGuti('TR', 'RED', theme.redColor);
    this.addGuti('B', 'BLUE', theme.blueColor);
    this.addGuti('BL', 'BLUE', theme.blueColor);
    this.addGuti('BR', 'BLUE', theme.blueColor);

    // ── In-Canvas UI ──
    this.createTopBar(theme);
    this.createGearButton();
    this.createSettingsPanel(theme);
    this.createBottomBar(theme);
    this.bindSliderEvents();

    // ── Background Image Input ──
    const bgInput = document.getElementById('bg-image-input') as HTMLInputElement;
    if (bgInput) {
      bgInput.addEventListener('change', (e: Event) => {
        const file = (e.target as HTMLInputElement).files?.[0];
        if (file) this.uploadBackgroundImage(file);
        bgInput.value = '';
      });
    }

    (window as any).gameScene = this;
  }

  // ────────────────────────────────────────────
  //  BOARD / NODES
  // ────────────────────────────────────────────

  private drawNodes(theme: any): void {
    Object.entries(NODES).forEach(([key, n]) => {
      const dot = this.add.circle(n.x, n.y, 8, theme.boardLineColor).setDepth(1);
      dot.setInteractive();
      dot.on('pointerdown', () => {
        if (this.settingsOpen) { this.closeSettings(); return; }
        this.hideMoveSlider();
        this.tryMove(key as NodeKey);
      });
    });
  }

  // ────────────────────────────────────────────
  //  GUTI
  // ────────────────────────────────────────────

  addGuti(nodeKey: NodeKey, owner: Player, color: number): void {
    const guti = new Guti(this, nodeKey, owner, color, this.gutiShape);
    guti.sprite.setDepth(5);
    this.occupied[nodeKey] = guti;
    this.gutis.push(guti);

    guti.sprite.on('pointerdown', () => {
      if (this.gameEnded || this.settingsOpen) return;

      // Own piece -> select it
      if (guti.owner === this.currentTurn) {
        this.clearHints();
        this.selectedGuti = guti;
        this.highlightSelection(guti);
        this.showValidMoves(guti);
        this.showMoveSliderFor(guti);
        return;
      }

    });
  }

  applyShapeToAll(shape: 'circle' | 'square' | 'bar'): void {
    const oldGutis = [...this.gutis];
    const newGutis: Guti[] = [];
    const newOccupied: Partial<Record<NodeKey, Guti>> = {};

    oldGutis.forEach(old => {
      const { nodeKey, owner } = old;
      const color = (old as any).color ??
        (owner === 'RED' ? this.themeManager.getCurrentTheme().redColor
                         : this.themeManager.getCurrentTheme().blueColor);
      try { old.sprite.destroy(); } catch (_) {}

      const ng = new Guti(this, nodeKey, owner, color, shape);
      ng.sprite.setDepth(5);
      newGutis.push(ng);
      newOccupied[nodeKey] = ng;

      ng.sprite.on('pointerdown', () => {
        if (this.gameEnded || this.settingsOpen) return;

        // Own piece -> select it
        if (ng.owner === this.currentTurn) {
          this.clearHints();
          this.selectedGuti = ng;
          this.highlightSelection(ng);
          this.showValidMoves(ng);
          this.showMoveSliderFor(ng);
          return;
        }

        // Opponent piece -> cannot eat or capture; do nothing
      });
    });

    this.gutis = newGutis;
    this.occupied = newOccupied;
    if (this.selectedGuti) {
      this.selectedGuti = this.occupied[this.selectedGuti.nodeKey] ?? null;
    }
  }

  // ────────────────────────────────────────────
  //  MOVEMENT
  // ────────────────────────────────────────────

  tryMove(target: NodeKey): void {
    if (this.gameEnded || !this.selectedGuti) return;
    const from = this.selectedGuti.nodeKey;

    // ONE-STEP ONLY: target must be an adjacent connected node
    if (!NODES[from].links.includes(target)) return;

    const occupant = this.occupied[target];

    // Empty adjacent node -> normal one-step move (no overlap)
    if (!occupant) {
      this.executeMove(from, target);
      return;
    }

    // Any piece on the node (own or opponent) -> blocked; cannot eat or capture
  }

  executeMove(from: NodeKey, to: NodeKey): void {
    this.selectedGuti!.moveTo(to, true, 300);
    delete this.occupied[from];
    this.occupied[to] = this.selectedGuti!;

    this.moveHistoryManager.recordMove(this.currentTurn, from, to);
    this.soundManager.playSlideSound();
    this.clearHints();
    this.clearSelection();
    this.hideMoveSlider();
    this.moveCount++;

    if (this.moveCount > 3) this.checkWin();
    this.switchTurn();
  }

  getAvailableTargets(guti: Guti): NodeKey[] {
    const from = guti.nodeKey;
    const targets: NodeKey[] = [];

    NODES[from].links.forEach(n => {
      const occupant = this.occupied[n];
      // Only empty nodes are valid move targets (no overlap, no captures)
      if (!occupant) targets.push(n);
    });

    return targets;
  }

  // ────────────────────────────────────────────
  //  HINTS
  // ────────────────────────────────────────────

  showValidMoves(guti: Guti): void {
    const from = guti.nodeKey;
    const theme = this.themeManager.getCurrentTheme();

    NODES[from].links.forEach(n => {
      // Only empty nodes are valid one-step move targets (no captures)
      const occupant = this.occupied[n];
      if (!occupant) this.drawHint(n, theme.hintNormalColor);
    });
  }

  drawHint(node: NodeKey, color: number): void {
    const n = NODES[node];
    const c = this.add.circle(n.x, n.y, 12, color, 0.4).setDepth(3);
    this.moveHints.push(c);
  }

  clearHints(): void {
    this.moveHints.forEach(h => h.destroy());
    this.moveHints = [];
  }

  // ────────────────────────────────────────────
  //  TURN
  // ────────────────────────────────────────────

  switchTurn(): void {
    this.currentTurn = this.currentTurn === 'RED' ? 'BLUE' : 'RED';
    this.updateTurnDisplay();
  }

  updateTurnDisplay(): void {
    const icon = this.currentTurn === 'RED' ? '🔴' : '🔵';
    this.turnText.setText(`${icon} ${this.currentTurn}'s Turn`);
    this.updateBottomHint();
  }

  // ────────────────────────────────────────────
  //  WIN CHECK
  // ────────────────────────────────────────────

  checkWin(): void {
    for (const line of WIN_LINES) {
      const owners = line.map(n => this.occupied[n]?.owner);
      if (owners.every(o => o === 'RED')) { this.gameOver('RED'); return; }
      if (owners.every(o => o === 'BLUE')) { this.gameOver('BLUE'); return; }
    }
  }

  gameOver(winner: Player): void {
    this.gameEnded = true;
    this.soundManager.playYooSound();
    this.statsManager.recordWin(winner, this.moveCount);

    const overlay = this.add.rectangle(300, 300, 600, 600, 0x000000, 0.75).setDepth(230);
    const modal = this.add.rectangle(300, 300, 380, 280, 0xffffff).setDepth(231);

    this.add.text(300, 220, '👑', { fontSize: '40px' }).setOrigin(0.5).setDepth(232);
    this.add.text(300, 260, `${winner} WINS!`, {
      fontSize: '36px',
      color: winner === 'RED' ? '#ff0000' : '#0000ff',
      fontStyle: 'bold',
    }).setOrigin(0.5).setDepth(232);
    this.add.text(300, 295, `Moves: ${this.moveCount}`, {
      fontSize: '16px', color: '#000',
    }).setOrigin(0.5).setDepth(232);

    const btn = this.add.rectangle(300, 355, 160, 42, 0x4CAF50).setDepth(232).setInteractive();
    this.add.text(300, 355, 'Play Again', {
      fontSize: '18px', color: '#fff', fontStyle: 'bold',
    }).setOrigin(0.5).setDepth(233);
    btn.on('pointerdown', () => this.scene.restart());
  }

  // ────────────────────────────────────────────
  //  SELECTION
  // ────────────────────────────────────────────

  highlightSelection(guti: Guti): void {
    this.gutis.forEach(g => g.sprite.setStrokeStyle());
    guti.sprite.setStrokeStyle(3, 0x00aa00);
  }

  clearSelection(): void {
    this.selectedGuti = null;
    this.gutis.forEach(g => g.sprite.setStrokeStyle());
  }

  // ────────────────────────────────────────────
  //  TOP BAR  —  Turn indicator
  // ────────────────────────────────────────────

  private createTopBar(_theme: any): void {
    const bar = this.add.rectangle(300, 18, 596, 30, 0x000000, 0.15).setDepth(6);
    bar.setStrokeStyle(1, 0x000000, 0.1);
    this.turnText = this.add.text(300, 18, `🔴 RED's Turn`, {
      fontSize: '14px', color: '#ffffff', fontStyle: 'bold',
    }).setOrigin(0.5).setDepth(7);
  }

  // ────────────────────────────────────────────
  //  GEAR BUTTON  —  top-right corner
  // ────────────────────────────────────────────

  private createGearButton(): void {
    const bg = this.add.rectangle(575, 18, 30, 30, 0x333333, 0.8)
      .setDepth(8).setInteractive({ useHandCursor: true });

    this.gearText = this.add.text(575, 18, '⚙', {
      fontSize: '16px', color: '#ffffff',
    }).setOrigin(0.5).setDepth(9);

    bg.on('pointerdown', () => this.openSettings());
    bg.on('pointerover', () => bg.setFillStyle(0x555555, 1));
    bg.on('pointerout', () => bg.setFillStyle(0x333333, 0.8));
  }

  // ────────────────────────────────────────────
  //  BOTTOM BAR  —  Shape info + hint
  // ────────────────────────────────────────────

  private createBottomBar(_theme: any): void {
    const bar = this.add.rectangle(300, 582, 596, 30, 0x000000, 0.15).setDepth(6);
    bar.setStrokeStyle(1, 0x000000, 0.1);

    (this as any)._bottomShapeLabel = this.add.text(20, 582, this.getShapeLabel(), {
      fontSize: '12px', color: '#cccccc',
    }).setOrigin(0, 0.5).setDepth(7);

    (this as any)._bottomHint = this.add.text(580, 582, 'Select a guti', {
      fontSize: '12px', color: '#aaaaaa',
    }).setOrigin(1, 0.5).setDepth(7);
  }

  private getShapeLabel(): string {
    const icons: Record<string, string> = { circle: '●', square: '■', bar: '│' };
    return `Shape: ${icons[this.gutiShape]}`;
  }

  private updateBottomHint(): void {
    const el = (this as any)._bottomHint as Phaser.GameObjects.Text | undefined;
    if (!el) return;
    if (this.gameEnded) { el.setText('Game Over'); return; }
    if (this.selectedGuti) {
      const targets = this.getAvailableTargets(this.selectedGuti);
      el.setText(targets.length > 0 ? `${targets.length} move(s) available` : 'No moves — select another');
    } else {
      el.setText(`Tap a ${this.currentTurn} guti`);
    }
  }

  // ────────────────────────────────────────────
  //  SETTINGS PANEL
  // ────────────────────────────────────────────

  private createSettingsPanel(theme: any): void {
    this.settingsPanel = this.add.group();

    // Dark overlay — click to close
    this.darkOverlay = this.add.rectangle(300, 300, 600, 600, 0x000000, 0.65)
      .setDepth(200).setInteractive();
    this.darkOverlay.on('pointerdown', () => this.closeSettings());
    this.settingsPanel.add(this.darkOverlay);

    // Panel box
    const panel = this.add.rectangle(300, 300, 300, 480, 0xffffff).setDepth(201);
    panel.setStrokeStyle(2, 0x333333);
    this.settingsPanel.add(panel);

    // Title
    this.settingsPanel.add(
      this.add.text(300, 115, '⚙ Settings', {
        fontSize: '18px', color: '#333', fontStyle: 'bold',
      }).setOrigin(0.5).setDepth(202)
    );

    // Close X
    const closeBg = this.add.rectangle(435, 108, 26, 26, 0xff4444).setDepth(202)
      .setInteractive({ useHandCursor: true });
    closeBg.on('pointerdown', () => this.closeSettings());
    closeBg.on('pointerover', () => closeBg.setFillStyle(0xff6666));
    closeBg.on('pointerout', () => closeBg.setFillStyle(0xff4444));
    this.settingsPanel.add(closeBg);
    this.settingsPanel.add(
      this.add.text(435, 108, '✕', { fontSize: '14px', color: '#fff' })
        .setOrigin(0.5).setDepth(203)
    );

    // ── Theme Button ──
    this.makePanelBtn(165, 170, `THEME: ${theme.name}`, 0x4CAF50, (txt) => {
      const t = this.themeManager.nextTheme();
      this.soundManager.playMoveSound();
      txt.setText(`THEME: ${t.name}`);
      this.cameras.main.setBackgroundColor(t.backgroundColor);
      this.scene.restart();
    });

    // ── Sound Button ──
    this.makePanelBtn(165, 215, `SOUND: ${this.soundManager.isSoundEnabled() ? 'ON' : 'OFF'}`, 0x2196F3, (txt) => {
      this.soundManager.toggleSound();
      txt.setText(`SOUND: ${this.soundManager.isSoundEnabled() ? 'ON' : 'OFF'}`);
    });

    // ── Stats Button ──
    this.makePanelBtn(165, 260, 'STATS', 0x9C27B0, () => {
      this.closeSettings();
      this.showStats();
    });

    // ── Undo Button ──
    this.makePanelBtn(165, 305, 'UNDO', 0xFF9800, () => {
      this.closeSettings();
      this.undoMove();
    });

    // ── Shape Cycle Button ──
    const shapeNames: Record<string, string> = { circle: 'Circle', square: 'Square', bar: 'Stick' };
    const shapeOrder: Array<'circle' | 'square' | 'bar'> = ['circle', 'square', 'bar'];
    this.makePanelBtn(165, 350, `SHAPE: ${shapeNames[this.gutiShape]}`, 0x607D8B, (txt) => {
      const idx = (shapeOrder.indexOf(this.gutiShape) + 1) % shapeOrder.length;
      this.gutiShape = shapeOrder[idx];
      this.applyShapeToAll(this.gutiShape);
      txt.setText(`SHAPE: ${shapeNames[this.gutiShape]}`);
      // Update bottom bar shape label
      const bottomLabel = (this as any)._bottomShapeLabel as Phaser.GameObjects.Text | undefined;
      if (bottomLabel) bottomLabel.setText(this.getShapeLabel());
    });

    // ── Guti Color Pair Button (opens color picker) ──
    this.makePanelBtn(165, 395, '🎨 GUTI COLOR', 0x3F51B5, () => {
      this.toggleColorPicker();
    });

    // ── Background Picker Trigger (opens grid) ──
    this.makePanelBtn(165, 440, '🎨 BACKGROUND', 0x795548, () => {
      this.toggleBackgroundPicker();
    });

    // ── How to Play Button ──
    this.makePanelBtn(165, 490, '❓ HOW TO PLAY', 0x009688, () => {
      this.closeSettings();
      this.showHowToPlay();
    });

    // Hide by default
    this.settingsPanel.setVisible(false);
  }

  // ────────────────────────────────────────────
  //  HOW TO PLAY
  // ────────────────────────────────────────────

  showHowToPlay(): void {
    const group: Phaser.GameObjects.GameObject[] = [];
    const destroyAll = () => group.forEach(o => { try { o.destroy(); } catch (_) {} });

    // ── Gaming-vibes "How to Play" overlay ──
    const overlay = this.add.rectangle(300, 300, 600, 600, 0x000000, 0.78).setDepth(280)
      .setInteractive();
    group.push(overlay);

    // Glow ring behind panel
    group.push(this.add.rectangle(300, 300, 432, 482, 0xffcc00, 0.15).setDepth(280.5));

    // Panel: dark "game card" with glowing border
    const panel = this.add.rectangle(300, 300, 420, 470, 0x1b1b2f).setDepth(281);
    panel.setStrokeStyle(3, 0xffcc00, 1);
    group.push(panel);

    // Top accent bar
    group.push(this.add.rectangle(300, 82, 420, 3, 0xffcc00, 1).setDepth(282));

    // Title
    group.push(this.add.text(300, 98, '🎮  HOW TO PLAY', {
      fontSize: '24px', fontStyle: 'bold', color: '#ffcc00',
      stroke: '#000', strokeThickness: 4,
    }).setOrigin(0.5).setDepth(282));

    // Subtitle
    group.push(this.add.text(300, 130, 'Bangla Guti Game', {
      fontSize: '13px', fontStyle: 'italic', color: '#9aa0d0',
    }).setOrigin(0.5).setDepth(282));

    // Content rows (icon + colored bullet + label)
    const rows: Array<{ icon: string; text: string; color: string }> = [
      { icon: '👥', text: '2 players, 3 gutis each', color: '#ffffff' },
      { icon: '👆', text: 'Tap your guti to select it', color: '#ffffff' },
      { icon: '🟢', text: 'Green ring = legal move (1 step)', color: '#7CFC00' },
      { icon: '🚫', text: 'No jumping, no overlapping', color: '#FF6B6B' },
      { icon: '🚫', text: 'No capturing / eating stones', color: '#FF6B6B' },
      { icon: '🏆', text: 'Line up all 3 to WIN!', color: '#ffcc00' },
    ];

    const startY = 165;
    const rowH = 34;
    rows.forEach((r, i) => {
      const y = startY + i * rowH;
      // row background for readability
      group.push(this.add.rectangle(210, y + 5, 360, 28, 0x26264a, 0.5).setDepth(281.5));
      // icon
      group.push(this.add.text(120, y + 5, r.icon, { fontSize: '15px' }).setOrigin(0.5).setDepth(282));
      // text
      group.push(this.add.text(160, y + 5, r.text, {
        fontSize: '14px', color: r.color,
      }).setOrigin(0, 0.5).setDepth(282));
    });

    // Tips box
    const tipBg = this.add.rectangle(210, 415, 360, 46, 0x26264a, 0.6).setDepth(281.5);
    tipBg.setStrokeStyle(1, 0xffcc00, 0.4);
    group.push(tipBg);
    group.push(this.add.text(210, 415, '💡 Tip: Use ⚙ to change colors,\n   background & guti shapes', {
      fontSize: '12px', color: '#9aa0d0', align: 'center',
    }).setOrigin(0.5).setDepth(282));

    // Close button (styled)
    const closeBg = this.add.rectangle(300, 468, 120, 34, 0xffcc00).setDepth(282)
      .setInteractive({ useHandCursor: true });
    closeBg.on('pointerover', () => closeBg.setFillStyle(0xffd633));
    closeBg.on('pointerout', () => closeBg.setFillStyle(0xffcc00));
    group.push(closeBg);
    const closeTxt = this.add.text(300, 468, 'LET’S PLAY ▶', {
      fontSize: '14px', fontStyle: 'bold', color: '#1b1b2f',
    }).setOrigin(0.5).setDepth(283);
    group.push(closeTxt);

    overlay.on('pointerdown', destroyAll);
    closeBg.on('pointerdown', destroyAll);
  }

  // ────────────────────────────────────────────
  //  GUTI COLOR PAIR PICKER
  // ────────────────────────────────────────────

  // Predefined guti color pairs (first = Player 1/RED side, second = Player 2/BLUE side)
  static readonly COLOR_PAIRS: Array<{ name: string; p1: number; p2: number }> = [
    { name: 'Red vs Blue',   p1: 0xff0000, p2: 0x0000ff },
    { name: 'Green vs Orange', p1: 0x00aa00, p2: 0xff8c00 },
    { name: 'Pink vs Teal',  p1: 0xe91e63, p2: 0x00bcd4 },
    { name: 'Yellow vs Purple', p1: 0xffd000, p2: 0x9c27b0 },
    { name: 'White vs Black', p1: 0xffffff, p2: 0x111111 },
    { name: 'Brown vs Cyan', p1: 0x8d6e63, p2: 0x00b7eb },
  ];

  private toggleColorPicker(): void {
    if (this.colorPickerOpen) {
      this.hideColorPicker();
      return;
    }
    this.openColorPicker();
  }

  private openColorPicker(): void {
    this.colorPickerOpen = true;
    this.colorPickerObjects = [];

    const overlay = this.add.rectangle(300, 300, 600, 600, 0x000000, 0.4)
      .setDepth(260).setInteractive();
    overlay.on('pointerdown', () => this.hideColorPicker());
    this.colorPickerObjects.push(overlay);

    const box = this.add.rectangle(300, 300, 320, 360, 0xffffff).setDepth(261);
    box.setStrokeStyle(2, 0x555555);
    this.colorPickerObjects.push(box);

    const title = this.add.text(300, 145, 'Choose Guti Colors', {
      fontSize: '16px', fontStyle: 'bold', color: '#333',
    }).setOrigin(0.5).setDepth(262);
    this.colorPickerObjects.push(title);

    // swatch grid
    const startX = 300 - 110;
    const startY = 195;
    const spacingX = 110;
    const spacingY = 70;

    GameScene.COLOR_PAIRS.forEach((pair, i) => {
      const col = i % 2;
      const row = Math.floor(i / 2);
      const x = startX + col * spacingX;
      const y = startY + row * spacingY;

      // pair swatch: two side-by-side colored circles + border
      const frame = this.add.rectangle(x, y, 96, 44, 0xffffff)
        .setStrokeStyle(2, 0xcccccc).setDepth(261);
      this.colorPickerObjects.push(frame);

      const c1 = this.add.circle(x - 14, y, 12, pair.p1).setDepth(262);
      const c2 = this.add.circle(x + 14, y, 12, pair.p2).setDepth(262);
      this.colorPickerObjects.push(c1);
      this.colorPickerObjects.push(c2);

      const nameT = this.add.text(x, y + 34, pair.name, {
        fontSize: '10px', color: '#333',
      }).setOrigin(0.5, 0).setDepth(262);
      this.colorPickerObjects.push(nameT);

      // + y offset for the label: make the whole swatch an interactive zone
      const zone = this.add.rectangle(x, y, 96, 56, 0xffffff, 0).setDepth(263)
        .setInteractive({ useHandCursor: true });
      zone.on('pointerover', () => frame.setStrokeStyle(3, 0x4CAF50));
      zone.on('pointerout', () => frame.setStrokeStyle(2, 0xcccccc));
      zone.on('pointerdown', (p: Phaser.Input.Pointer) => {
        p.event.stopPropagation();
        this.applyColorPair(i);
        this.hideColorPicker();
      });
      this.colorPickerObjects.push(zone);
    });

    this.updateBottomHint();
  }

  private hideColorPicker(): void {
    if (!this.colorPickerOpen) return;
    this.colorPickerOpen = false;
    this.colorPickerObjects.forEach(o => { try { o.destroy(); } catch (_) {} });
    this.colorPickerObjects = [];
    this.updateBottomHint();
  }

  private applyColorPair(index: number): void {
    const pairs = GameScene.COLOR_PAIRS;
    if (index < 0 || index >= pairs.length) return;
    this.currentColorPairIndex = index;
    const pair = pairs[index];

    // Recolor both sets of gutis in place (preserve nodeKey/owner)
    this.gutis.forEach(g => {
      const color = g.owner === 'RED' ? pair.p1 : pair.p2;
      g.color = color;
      g.sprite.setFillStyle(color);
    });
    this.soundManager.playMoveSound();
  }

  // ── Background Picker Grid (5 presets + upload) ──
  private toggleBackgroundPicker(): void {
    if (this.bgSelectionOpen) {
      this.hideBackgroundPicker();
      return;
    }
    this.openBackgroundPicker();
  }

  private openBackgroundPicker(): void {
    this.bgSelectionOpen = true;
    this.bgPickerObjects = [];

    // Overlay to catch outside clicks
    const overlay = this.add.rectangle(300, 300, 600, 600, 0x000000, 0.4)
      .setDepth(240).setInteractive();
    overlay.on('pointerdown', () => this.hideBackgroundPicker());
    this.bgPickerObjects.push(overlay);

    const box = this.add.rectangle(300, 300, 340, 350, 0xffffff).setDepth(241);
    box.setStrokeStyle(2, 0x555555);
    this.bgPickerObjects.push(box);

    const title = this.add.text(300, 160, 'Choose Background', {
      fontSize: '16px', fontStyle: 'bold', color: '#333',
    }).setOrigin(0.5).setDepth(242);
    this.bgPickerObjects.push(title);

    // 6 preset thumbnails in a grid (3 columns x 2 rows)
    const startX = 300 - 105;
    const startY = 215;
    const spacing = 75;

    BACKGROUND_OPTIONS.forEach((opt, i) => {
      const col = i % 3;
      const row = Math.floor(i / 3);
      const x = startX + col * spacing;
      const y = startY + row * 80;

      const texKey = this.backgroundManager.getDefaultTextureKey(opt.id);
      if (!texKey) return;

      // border frame behind thumb
      const frame = this.add.rectangle(x, y, 66, 66, 0xffffff)
        .setStrokeStyle(2, 0xcccccc).setDepth(241);
      this.bgPickerObjects.push(frame);

      const thumb = this.add.image(x, y, texKey)
        .setDisplaySize(58, 58)
        .setDepth(242)
        .setInteractive({ useHandCursor: true });

      thumb.on('pointerover', () => { frame.setStrokeStyle(3, 0x4CAF50); });
      thumb.on('pointerout', () => { frame.setStrokeStyle(2, 0xcccccc); });
      thumb.on('pointerdown', (p: Phaser.Input.Pointer) => {
        p.event.stopPropagation();
        this.setDefaultBackground(opt.id);
        this.hideBackgroundPicker();
      });

      this.bgThumbs.push(thumb);
      this.bgPickerObjects.push(thumb);

      const label = this.add.text(x, y + 42, opt.label, {
        fontSize: '11px', color: '#333',
      }).setOrigin(0.5).setDepth(242);
      this.bgPickerObjects.push(label);

      const iconT = this.add.text(x - 24, y - 28, opt.icon, {
        fontSize: '12px',
      }).setOrigin(0.5).setDepth(242);
      this.bgPickerObjects.push(iconT);
    });

    // Upload button below grid
    const uploadBg = this.add.rectangle(300, 450, 240, 34, 0x2196F3).setDepth(242)
      .setInteractive({ useHandCursor: true });
    this.bgPickerObjects.push(uploadBg);

    const uploadTxt = this.add.text(300, 450, '📁 Upload from Device', {
      fontSize: '13px', fontStyle: 'bold', color: '#fff',
    }).setOrigin(0.5).setDepth(243);
    this.bgPickerObjects.push(uploadTxt);

    uploadBg.on('pointerdown', (p: Phaser.Input.Pointer) => {
      p.event.stopPropagation();
      this.hideBackgroundPicker();
      document.getElementById('bg-image-input')?.click();
    });
  }

  private hideBackgroundPicker(): void {
    if (!this.bgSelectionOpen) return;
    this.bgSelectionOpen = false;
    this.bgThumbs = [];
    this.bgPickerObjects.forEach(o => { try { o.destroy(); } catch (_) {} });
    this.bgPickerObjects = [];
    this.updateBottomHint();
  }

  setDefaultBackground(id: string): void {
    const texKey = this.backgroundManager.getDefaultTextureKey(id);
    if (!texKey) return;
    this.resetBackgroundImage();
    this.bgImage = this.add.image(300, 300, texKey)
      .setDisplaySize(600, 600)
      .setDepth(-10);
  }

  private makePanelBtn(
    x: number, y: number, label: string, color: number,
    onClick: (txt: Phaser.GameObjects.Text) => void
  ): void {
    const w = 200, h = 32;
    const bg = this.add.rectangle(x, y, w, h, color).setDepth(202)
      .setInteractive({ useHandCursor: true });
    const txt = this.add.text(x, y, label, {
      fontSize: '13px', color: '#ffffff', fontStyle: 'bold',
    }).setOrigin(0.5).setDepth(203);

    bg.on('pointerdown', (p: Phaser.Input.Pointer) => {
      p.event.stopPropagation();
      onClick(txt);
    });
    bg.on('pointerover', () => bg.setFillStyle(color, 0.85));
    bg.on('pointerout', () => bg.setFillStyle(color, 1));

    this.settingsPanel.addMultiple([bg, txt]);
  }

  openSettings(): void {
    this.settingsOpen = true;
    this.settingsPanel.setVisible(true);
    this.updateBottomHint();
  }

  closeSettings(): void {
    this.settingsOpen = false;
    this.settingsPanel.setVisible(false);
    this.updateBottomHint();
  }

  // ────────────────────────────────────────────
  //  SETTINGS ACTIONS
  // ────────────────────────────────────────────

  showStats(): void {
    const stats = this.statsManager.getStats();
    const lines = [
      `Red Wins: ${stats.redWins}`,
      `Blue Wins: ${stats.blueWins}`,
      `Total Games: ${stats.totalGames}`,
      `Avg Moves: ${stats.averageMoves}`,
    ];

    const overlay = this.add.rectangle(300, 300, 600, 600, 0x000000, 0.6).setDepth(220)
      .setInteractive();
    const box = this.add.rectangle(300, 300, 260, 200, 0xffffff).setDepth(221);
    const title = this.add.text(300, 220, '📊 Stats', {
      fontSize: '16px', fontStyle: 'bold', color: '#333',
    }).setOrigin(0.5).setDepth(222);
    const body = this.add.text(300, 265, lines.join('\n'), {
      fontSize: '14px', color: '#333', align: 'center', lineSpacing: 6,
    }).setOrigin(0.5).setDepth(222);

    const dismiss = [overlay, box, title, body];
    overlay.on('pointerdown', () => dismiss.forEach(o => o.destroy()));

    this.time.delayedCall(4000, () => dismiss.forEach(o => { try { o.destroy(); } catch (_) {} }));
  }

  undoMove(): void {
    if (this.moveHistoryManager.getMoveCount() < 1) return;

    const last = this.moveHistoryManager.undoLastMove();
    if (!last) return;

    this.soundManager.playMoveSound();

    // Move guti back
    const guti = this.occupied[last.to];
    if (guti) {
      guti.moveTo(last.from, true);
      delete this.occupied[last.to];
      this.occupied[last.from] = guti;
    }

    this.moveCount--;
    this.currentTurn = last.player;
    this.updateTurnDisplay();
    this.updateBottomHint();
  }

  // ────────────────────────────────────────────
  //  BACKGROUND IMAGE
  // ────────────────────────────────────────────

  uploadBackgroundImage(file: File): void {
    const reader = new FileReader();
    reader.onload = (e) => {
      const dataUrl = e.target?.result as string;
      if (!dataUrl) return;

      // Remove old BG image
      this.resetBackgroundImage();

      const texKey = 'custom-bg-' + Date.now();
      this.textures.addBase64(texKey, dataUrl);

      const showBg = () => {
        this.bgImage = this.add.image(300, 300, texKey)
          .setDisplaySize(600, 600)
          .setDepth(-10);
        this.cameras.main.setBackgroundColor(
          this.themeManager.getCurrentTheme().backgroundColor
        );
      };

      // addBase64 loads async — wait for the ADD texture event, with a polling fallback
      const onAdd = (key: string) => {
        if (key === texKey) {
          this.textures.off('addtexture', onAdd);
          showBg();
        }
      };
      this.textures.on('addtexture', onAdd);

      // Fallback: if texture already exists within a tick, show immediately
      this.time.delayedCall(50, () => {
        if (this.textures.exists(texKey)) {
          this.textures.off('addtexture', onAdd);
          showBg();
        }
      });
    };
    reader.readAsDataURL(file);
  }

  resetBackgroundImage(): void {
    if (this.bgImage) {
      this.bgImage.destroy();
      this.bgImage = null;
    }
  }

  // ────────────────────────────────────────────
  //  MOVE SLIDER (mobile)
  // ────────────────────────────────────────────

  showMoveSliderFor(guti: Guti): void {
    const wrap = document.getElementById('move-slider-wrap');
    const slider = document.getElementById('move-slider') as HTMLInputElement | null;
    const label = document.getElementById('slider-label');
    if (!wrap || !slider || !label) return;

    const targets = this.getAvailableTargets(guti);
    this.sliderTargets = targets;

    if (targets.length === 0) {
      wrap.style.display = 'none';
      return;
    }

    slider.min = '0';
    slider.max = `${targets.length - 1}`;
    slider.value = '0';
    label.innerText = `Move to ${targets[0]}`;
    wrap.style.display = 'block';

    this.clearHints();
    this.drawHint(targets[0], this.themeManager.getCurrentTheme().hintNormalColor);
  }

  hideMoveSlider(): void {
    const wrap = document.getElementById('move-slider-wrap');
    if (wrap) wrap.style.display = 'none';
    this.sliderTargets = [];
  }

  // ── Bind slider & buttons (called once) ──
  bindSliderEvents(): void {
    const slider = document.getElementById('move-slider') as HTMLInputElement | null;
    const label = document.getElementById('slider-label');
    const btnMove = document.getElementById('btn-move');
    const btnCancel = document.getElementById('btn-cancel-move');

    slider?.addEventListener('input', () => {
      const idx = parseInt(slider.value, 10) || 0;
      const target = this.sliderTargets[idx];
      if (label && target) label.innerText = `Move to ${target}`;
      this.clearHints();
      if (target) this.drawHint(target, this.themeManager.getCurrentTheme().hintNormalColor);
    });

    btnMove?.addEventListener('click', () => {
      if (!this.selectedGuti) return;
      const idx = parseInt(slider?.value ?? '0', 10) || 0;
      const target = this.sliderTargets[idx];
      if (target) this.tryMove(target);
      this.hideMoveSlider();
    });

    btnCancel?.addEventListener('click', () => this.hideMoveSlider());
  }
}

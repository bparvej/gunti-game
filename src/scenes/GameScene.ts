import Phaser from 'phaser';
import { Board } from '../board/Board';
import { NODES, NodeKey } from '../board/Nodes';
import { Guti, Player } from '../guti/Guti';
import { WIN_LINES } from '../board/WinLines';

export class GameScene extends Phaser.Scene {
  gutis: Guti[] = [];
  selectedGuti: Guti | null = null;

  occupied: Partial<Record<NodeKey, Guti>> = {};

  currentTurn: Player = 'RED';
  moveHints: Phaser.GameObjects.Circle[] = [];
  moveCount: number = 0;


  constructor() {
    super('GameScene');
  }

  create(): void {
    new Board(this);

    // Draw nodes
    Object.entries(NODES).forEach(([key, n]) => {
      const dot = this.add.circle(n.x, n.y, 8, 0x000000);
      dot.setInteractive();

      dot.on('pointerdown', () => {
        this.tryMove(key as NodeKey);
      });
    });

    // ---- GUTI SETUP ----
    this.addGuti('T', 'RED', 0xff0000);
    this.addGuti('TL', 'RED', 0xff0000);
    this.addGuti('TR', 'RED', 0xff0000);

    this.addGuti('B', 'BLUE', 0x0000ff);
    this.addGuti('BL', 'BLUE', 0x0000ff);
    this.addGuti('BR', 'BLUE', 0x0000ff);

    this.add.text(40, 20, 'Turn: RED', {
      fontSize: '18px',
      color: '#000'
    }).setName('turnText');
  }

  /* ---------------- GUTI ---------------- */

  addGuti(nodeKey: NodeKey, owner: Player, color: number): void {
    const guti = new Guti(this, nodeKey, owner, color);

    this.occupied[nodeKey] = guti;
    this.gutis.push(guti);

    guti.sprite.on('pointerdown', () => {
      if (guti.owner !== this.currentTurn) return;

      this.clearHints();
      this.selectedGuti = guti;
      this.highlightSelection(guti);
      this.showValidMoves(guti);
    });
  }

  /* ---------------- MOVEMENT ---------------- */

  tryMove(target: NodeKey): void {
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
    }
  }

  executeMove(from: NodeKey, to: NodeKey): void {
    delete this.occupied[from];
    this.occupied[to] = this.selectedGuti!;

    this.selectedGuti!.moveTo(to);
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

    guti.sprite.destroy();
    this.gutis = this.gutis.filter(g => g !== guti);
    delete this.occupied[node];
  }

  /* ---------------- HIGHLIGHT ---------------- */

  showValidMoves(guti: Guti): void {
    const from = guti.nodeKey;

    NODES[from].links.forEach(n => {
      if (!this.occupied[n]) {
        this.drawHint(n, 0x00ff00);
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
        this.drawHint(target, 0xffaa00);
      }
    });
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
    const text = this.children.getByName('turnText') as Phaser.GameObjects.Text;
    text.setText(`Turn: ${this.currentTurn}`);
  }

  /* ---------------- WIN CHECK ---------------- */

  checkWin(): void {
    for (const line of WIN_LINES) {
      const owners = line.map(n => this.occupied[n]?.owner);
      if (owners.every(o => o === 'RED')) {
        this.gameOver('RED');
      }
      if (owners.every(o => o === 'BLUE')) {
        this.gameOver('BLUE');
      }
    }
  }

  gameOver(winner: Player): void {
    this.add.rectangle(300, 300, 600, 600, 0x000000, 0.6);
    this.add.text(300, 300, `${winner} WINS!`, {
      fontSize: '40px',
      color: '#ffffff'
    }).setOrigin(0.5);

    this.input.enabled = false;
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

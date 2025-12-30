import Phaser from 'phaser';
import { Board } from '../board/Board';
import { Guti } from '../guti/Guti';

export class GameScene extends Phaser.Scene {
  constructor() {
    super('GameScene');
  }

  create(): void {
    console.log('✅ GameScene with Board + Guti');

    // Draw board
    new Board(this);

    // ---- INTERSECTION COORDINATES ----
    const TOP = { x: 300, y: 100 };
    const BOTTOM = { x: 300, y: 500 };

    // ---- RED GUTI (TOP) ----
    new Guti(this, TOP.x - 190, TOP.y, 0xff0000);
    new Guti(this, TOP.x,      TOP.y, 0xff0000);
    new Guti(this, TOP.x + 190, TOP.y, 0xff0000);

    // ---- BLUE GUTI (BOTTOM) ----
    new Guti(this, BOTTOM.x - 190, BOTTOM.y, 0x0000ff);
    new Guti(this, BOTTOM.x,      BOTTOM.y, 0x0000ff);
    new Guti(this, BOTTOM.x + 190, BOTTOM.y, 0x0000ff);

    // Debug text
    this.add.text(150, 20, 'BOARD + RED & BLUE GUTI', {
      fontSize: '18px',
      color: '#000'
    });
  }
}

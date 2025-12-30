import Phaser from 'phaser';

export class Board {
  constructor(scene: Phaser.Scene) {
    const g = scene.add.graphics();
    g.lineStyle(3, 0x000000);

    const cx = 300;
    const cy = 300;
    const half = 200;

    // Outer square
    g.strokeRect(cx - half, cy - half, 400, 400);

    // Vertical & horizontal
    g.lineBetween(cx, cy - half, cx, cy + half);
    g.lineBetween(cx - half, cy, cx + half, cy);

    // Diagonals
    g.lineBetween(cx - half, cy - half, cx + half, cy + half);
    g.lineBetween(cx - half, cy + half, cx + half, cy - half);
  }
}

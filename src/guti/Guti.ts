import Phaser from 'phaser';

export class Guti {
  sprite: Phaser.GameObjects.Arc;

  constructor(
    scene: Phaser.Scene,
    x: number,
    y: number,
    color: number
  ) {
    this.sprite = scene.add.circle(x, y, 14, color);
  }
}

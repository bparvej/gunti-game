import Phaser from 'phaser';
import { NodeKey, NODES } from '../board/Nodes';

export type Player = 'RED' | 'BLUE';

export type Shape = 'circle' | 'square' | 'bar' | 'lalbadshah';

export class Guti {
  sprite: any;
  nodeKey: NodeKey;
  owner: Player;
  scene: Phaser.Scene;
  color: number;

  constructor(
    scene: Phaser.Scene,
    nodeKey: NodeKey,
    owner: Player,
    color: number,
    shape: Shape = 'circle'
  ) {
    this.nodeKey = nodeKey;
    this.owner = owner;
    this.scene = scene;
    this.color = color;

    const node = NODES[nodeKey];
    if (shape === 'lalbadshah') {
      // Lal Badshah (Red King) vs Joker/Gulam — themed pair shape.
      // Textures 'guti-king' (RED) and 'guti-joker' (BLUE) are generated
      // procedurally by GameScene.ensureBadshahTextures().
      const texKey = owner === 'RED' ? 'guti-king' : 'guti-joker';
      this.sprite = scene.add.image(node.x, node.y, texKey).setDisplaySize(34, 38);
    } else if (shape === 'circle') {
      this.sprite = scene.add.circle(node.x, node.y, 14, color);
    } else if (shape === 'square') {
      this.sprite = scene.add.rectangle(node.x, node.y, 28, 28, color).setOrigin(0.5);
    } else {
      // bar / ঝাড়ুর কাঠি
      this.sprite = scene.add.rectangle(node.x, node.y, 10, 36, color).setOrigin(0.5);
    }

    // Large INVISIBLE hit area (radius 38) for comfortable finger tapping.
    // The visual stays unchanged; only the interactive footprint grows.
    this.sprite.setInteractive(
      new Phaser.Geom.Circle(0, 0, 38),
      Phaser.Geom.Circle.Contains
    );
  }

  moveTo(nodeKey: NodeKey, animate: boolean = true, duration: number = 300): void {
    this.nodeKey = nodeKey;
    const node = NODES[nodeKey];

    if (animate) {
      this.scene.tweens.add({
        targets: this.sprite,
        x: node.x,
        y: node.y,
        duration: duration,
        ease: 'Power2.easeInOut',
      });
    } else {
      this.sprite.setPosition(node.x, node.y);
    }
  }
}

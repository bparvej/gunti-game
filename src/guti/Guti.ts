import Phaser from 'phaser';
import { NodeKey, NODES } from '../board/Nodes';

export type Player = 'RED' | 'BLUE';

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
    shape: 'circle' | 'square' | 'bar' = 'circle'
  ) {
    this.nodeKey = nodeKey;
    this.owner = owner;
    this.scene = scene;
    this.color = color;

    const node = NODES[nodeKey];
    if (shape === 'circle') {
      this.sprite = scene.add.circle(node.x, node.y, 14, color);
    } else if (shape === 'square') {
      this.sprite = scene.add.rectangle(node.x, node.y, 28, 28, color).setOrigin(0.5);
    } else {
      // bar / ঝাড়ুর কাঠি
      this.sprite = scene.add.rectangle(node.x, node.y, 10, 36, color).setOrigin(0.5);
    }

    this.sprite.setInteractive();
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

  captureAnimation(onComplete?: () => void): void {
    this.scene.tweens.add({
      targets: this.sprite,
      scale: 1.5,
      alpha: 0,
      duration: 200,
      ease: 'Power2.easeOut',
      onComplete: onComplete,
    });
  }
}

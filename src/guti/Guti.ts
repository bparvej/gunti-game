import Phaser from 'phaser';
import { NodeKey, NODES } from '../board/Nodes';

export type Player = 'RED' | 'BLUE';

export class Guti {
  sprite: Phaser.GameObjects.Arc;
  nodeKey: NodeKey;
  owner: Player;

  constructor(
    scene: Phaser.Scene,
    nodeKey: NodeKey,
    owner: Player,
    color: number
  ) {
    this.nodeKey = nodeKey;
    this.owner = owner;

    const node = NODES[nodeKey];
    this.sprite = scene.add.circle(node.x, node.y, 14, color);

    this.sprite.setInteractive();
  }

  moveTo(nodeKey: NodeKey): void {
    this.nodeKey = nodeKey;
    const node = NODES[nodeKey];
    this.sprite.setPosition(node.x, node.y);
  }
}

import Phaser from 'phaser';
import { GameScene } from '../scenes/GameScene';

export interface Node {
  x: number;
  y: number;
  links: string[];
}

export interface NodeMap {
  [key: string]: Node;
}

export function createNodes(scene: GameScene): NodeMap {
  const nodes: NodeMap = {
    C: { x: 300, y: 300, links: ['T','B','L','R','TL','TR','BL','BR'] },
    T: { x: 300, y: 100, links: ['C'] },
    B: { x: 300, y: 500, links: ['C'] },
    L: { x: 100, y: 300, links: ['C'] },
    R: { x: 500, y: 300, links: ['C'] },
    TL:{ x: 100, y: 100, links: ['C'] },
    TR:{ x: 500, y: 100, links: ['C'] },
    BL:{ x: 100, y: 500, links: ['C'] },
    BR:{ x: 500, y: 500, links: ['C'] }
  };

  Object.keys(nodes).forEach(key => {
    const n = nodes[key];
    const dot = scene.add.circle(n.x, n.y, 6, 0x000000);
    dot.setInteractive();
    dot.on('pointerdown', () => scene.moveGuti(key));
  });

  return nodes;
}

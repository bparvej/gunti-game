import Phaser from 'phaser';
import { GameScene } from '../scenes/GameScene';

export const gameConfig: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,

  parent: 'game',          // 🔴 MUST exist in index.html

  width: 600,
  height: 600,

  backgroundColor: '#ffffff',

  scene: GameScene         // 🔴 single scene (auto-start)
};

import Phaser from 'phaser';
import { GameScene } from '../scenes/GameScene';
import { ThemeManager } from '../managers/ThemeManager';

const themeManager = new ThemeManager();
const currentTheme = themeManager.getCurrentTheme();

export const gameConfig: Phaser.Types.Core.GameConfig = {
  type: Phaser.AUTO,

  parent: 'game',          // 🔴 MUST exist in index.html

  width: 600,
  height: 600,

  backgroundColor: currentTheme.backgroundColor,

  scene: GameScene,

  scale: {
    mode: Phaser.Scale.FIT,
    autoCenter: Phaser.Scale.CENTER_BOTH,
  }
};

export { themeManager };

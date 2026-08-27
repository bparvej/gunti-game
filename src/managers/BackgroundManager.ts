import Phaser from 'phaser';

export interface BackgroundOption {
  id: string;
  label: string;
  icon: string;
}

// Preset procedural backgrounds the user can pick from
export const BACKGROUND_OPTIONS: BackgroundOption[] = [
  { id: 'green',   label: 'Grass',     icon: '🌿' },
  { id: 'wood',    label: 'Wood',      icon: '🪵' },
  { id: 'sky',     label: 'Sky',       icon: '☁️' },
  { id: 'night',   label: 'Night',     icon: '🌙' },
  { id: 'sand',    label: 'Sand',      icon: '🏖️' },
];

export class BackgroundManager {
  private scene: Phaser.Scene;
  private defaultTextureKeys: Record<string, string> = {};

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
    this.generateDefaults();
  }

  // Generate 5 procedural textures at scene start
  private generateDefaults(): void {
    this.generateGrass();
    this.generateWood();
    this.generateSky();
    this.generateNight();
    this.generateSand();
  }

  getDefaultTextureKey(id: string): string | null {
    return this.defaultTextureKeys[id] ?? null;
  }

  private generateGrass(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    g.fillStyle(0x3a9d23, 1);
    g.fillRect(0, 0, 600, 600);
    g.fillStyle(0x2d7d1b, 1);
    for (let y = 0; y < 600; y += 24) {
      g.fillRect(0, y, 600, 2);
    }
    const key = this.textureFromGraphics(g, 'bg-green');
    this.defaultTextureKeys['green'] = key;
  }

  private generateWood(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    g.fillStyle(0x8b5a2b, 1);
    g.fillRect(0, 0, 600, 600);
    g.lineStyle(2, 0x6e451d, 0.6);
    for (let x = 0; x <= 600; x += 50) {
      g.lineBetween(x, 0, x, 600);
    }
    const key = this.textureFromGraphics(g, 'bg-wood');
    this.defaultTextureKeys['wood'] = key;
  }

  private generateSky(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    g.fillStyle(0x87ceeb, 1);
    g.fillRect(0, 0, 600, 600);
    g.fillStyle(0xffffff, 0.9);
    for (let i = 0; i < 8; i++) {
      const cx = 40 + Math.random() * 520;
      const cy = 30 + Math.random() * 120;
      g.fillEllipse(cx, cy, 70, 22);
    }
    g.fillStyle(0x90ee90, 1);
    g.fillRect(0, 470, 600, 130);
    const key = this.textureFromGraphics(g, 'bg-sky');
    this.defaultTextureKeys['sky'] = key;
  }

  private generateNight(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    g.fillStyle(0x0b1026, 1);
    g.fillRect(0, 0, 600, 600);
    g.fillStyle(0xffffff, 1);
    for (let i = 0; i < 120; i++) {
      const sx = Math.random() * 600;
      const sy = Math.random() * 540;
      g.fillCircle(sx, sy, Math.random() * 1.5 + 0.5);
    }
    // moon
    g.fillStyle(0xfff8d0, 1);
    g.fillCircle(500, 80, 34);
    g.fillStyle(0x0b1026, 1);
    g.fillCircle(488, 72, 30);
    const key = this.textureFromGraphics(g, 'bg-night');
    this.defaultTextureKeys['night'] = key;
  }

  private generateSand(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    g.fillStyle(0xe8c377, 1);
    g.fillRect(0, 0, 600, 600);
    g.lineStyle(3, 0xd4b05f, 0.7);
    for (let y = 40; y < 600; y += 70) {
      g.lineBetween(0, y, 600, y);
    }
    g.fillStyle(0x47a3ff, 1);
    g.fillRect(0, 0, 600, 40);
    const key = this.textureFromGraphics(g, 'bg-sand');
    this.defaultTextureKeys['sand'] = key;
  }

  private textureFromGraphics(g: Phaser.GameObjects.Graphics, key: string): string {
    g.generateTexture(key, 600, 600);
    g.destroy();
    return key;
  }
}

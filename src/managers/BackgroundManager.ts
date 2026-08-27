import Phaser from 'phaser';

export interface BackgroundOption {
  id: string;
  label: string;
  icon: string;
}

// 5 sample backgrounds themed around the traditional Bengali Guti board game.
// These are hand-crafted illustrative backgrounds rendered to textures at runtime
// (no external image files needed — works offline, mirrors the classic wood/cloth
//  game mats on which the real game is played).
export const BACKGROUND_OPTIONS: BackgroundOption[] = [
  { id: 'teakwood', label: 'Teak Wood', icon: '🪵' },
  { id: 'velvet',   label: 'Velvet Red', icon: '🔴' },
  { id: 'greenmat', label: 'Green Mat', icon: '🌿' },
  { id: 'night',    label: 'Moonlit Night', icon: '🌙' },
  { id: 'marble',   label: 'Marble', icon: '🪨' },
  { id: 'dino',     label: 'Funny Dino', icon: '🦖' },
];

export class BackgroundManager {
  private scene: Phaser.Scene;
  private defaultTextureKeys: Record<string, string> = {};
  private generated = false;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
  }

  // Generate all sample backgrounds. Call from create() AFTER textures are ready.
  ensureGenerated(): void {
    if (this.generated) return;
    this.generated = true;
    this.generateTeakWood();
    this.generateVelvet();
    this.generateGreenMat();
    this.generateNight();
    this.generateMarble();
    this.generateDino();
  }

  getDefaultTextureKey(id: string): string | null {
    return this.defaultTextureKeys[id] ?? null;
  }

  // ── 1. Teak Wood ──────────────────────────────
  private generateTeakWood(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    // base wood
    g.fillStyle(0x9c6b30, 1);
    g.fillRect(0, 0, 600, 600);
    // soft gradient bands
    for (let i = 0; i < 14; i++) {
      const y = i * 45;
      g.fillStyle(0xa97536, 0.35);
      g.fillRect(0, y + 8, 600, 12);
    }
    // wood grains
    g.lineStyle(1.5, 0x7a4f1d, 0.5);
    for (let i = 0; i < 26; i++) {
      const y = i * 24;
      g.beginPath();
      g.moveTo(0, y);
      g.lineTo(150, y + 6);
      g.lineTo(300, y - 2);
      g.lineTo(450, y - 2);
      g.lineTo(600, y + 4);
      g.strokePath();
    }
    // corner carvings - subtle
    g.fillStyle(0x7a4f1d, 0.3);
    g.fillCircle(40, 40, 30);
    g.fillCircle(560, 40, 30);
    g.fillCircle(40, 560, 30);
    g.fillCircle(560, 560, 30);
    this.finish(g, 'bg-teakwood', 'teakwood');
  }

  // ── 2. Velvet Red (traditional playing cloth) ──
  private generateVelvet(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    // rich velvet red gradient
    g.fillStyle(0xb0171f, 1);
    g.fillRect(0, 0, 600, 600);
    // radial-ish light
    g.fillStyle(0xd23a41, 0.5);
    g.fillCircle(300, 300, 340);
    g.fillStyle(0xe05a60, 0.35);
    g.fillCircle(300, 300, 230);
    g.fillStyle(0xf08080, 0.25);
    g.fillCircle(300, 300, 140);
    // golden border frame
    g.lineStyle(6, 0xffd700, 0.9);
    g.strokeRectShape({ x: 12, y: 12, width: 576, height: 576 } as any);
    g.lineStyle(2, 0xd4af37, 0.7);
    g.strokeRectShape({ x: 28, y: 28, width: 544, height: 544 } as any);
    // corner gold dots
    g.fillStyle(0xffd700, 1);
    [[36,36],[564,36],[36,564],[564,564]].forEach(([x,y]) => {
      g.fillCircle(x, y, 8);
    });
    this.finish(g, 'bg-velvet', 'velvet');
  }

  // ── 3. Green Mat (jute/palm mat) ──
  private generateGreenMat(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    g.fillStyle(0x3f9d3f, 1);
    g.fillRect(0, 0, 600, 600);
    // woven texture - crisscross
    g.lineStyle(3, 0x357735, 0.45);
    for (let y = 0; y < 600; y += 28) g.lineBetween(0, y, 600, y);
    g.lineStyle(3, 0x4fae4f, 0.35);
    for (let x = 0; x < 600; x += 28) g.lineBetween(x, 0, x, 600);
    // subtle vignette
    g.fillStyle(0x1c4f1c, 0.18);
    g.fillRect(0, 500, 600, 100);
    // leaf sprinkle
    g.fillStyle(0x2f7a2f, 0.5);
    for (let i = 0; i < 24; i++) {
      g.fillEllipse(Math.random() * 580 + 10, Math.random() * 580 + 10, 10, 5);
    }
    this.finish(g, 'bg-greenmat', 'greenmat');
  }

  // ── 4. Moonlit Night ──
  private generateNight(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    // deep indigo
    g.fillStyle(0x141a3a, 1);
    g.fillRect(0, 0, 600, 600);
    // soft glow at center (moonlight)
    g.fillStyle(0x2a3560, 0.4);
    g.fillCircle(420, 120, 180);
    g.fillStyle(0x3a4a78, 0.3);
    g.fillCircle(420, 120, 120);
    // stars
    g.fillStyle(0xffffff, 1);
    for (let i = 0; i < 130; i++) {
      g.fillCircle(Math.random() * 600, Math.random() * 480, Math.random() * 1.6 + 0.5);
    }
    // moon with crater
    g.fillStyle(0xf5f3e0, 1);
    g.fillCircle(420, 120, 40);
    g.fillStyle(0xe0dcc0, 0.7);
    g.fillCircle(410, 110, 8);
    g.fillCircle(432, 132, 6);
    g.fillCircle(405, 130, 5);
    // distant hills
    g.fillStyle(0x0c1026, 1);
    g.fillTriangle(0, 600, 120, 430, 260, 600);
    g.fillTriangle(200, 600, 360, 400, 520, 600);
    g.fillTriangle(420, 600, 540, 440, 600, 600);
    // ground
    g.fillStyle(0x0a0d1f, 1);
    g.fillRect(0, 470, 600, 130);
    this.finish(g, 'bg-night', 'night');
  }

  // ── 5. Marble ──
  private generateMarble(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    // light marble base
    g.fillStyle(0xf0ede6, 1);
    g.fillRect(0, 0, 600, 600);
    // veins
    g.lineStyle(1.5, 0xb8b2a4, 0.5);
    for (let i = 0; i < 30; i++) {
      const y = Math.random() * 600;
      g.beginPath();
      g.moveTo(0, y);
      g.lineTo(150, y + 8);
      g.lineTo(300, y - 6);
      g.lineTo(450, y + 8);
      g.lineTo(600, y - 4);
      g.strokePath();
    }
    // soft patches
    g.fillStyle(0xd9d4c8, 0.5);
    for (let i = 0; i < 12; i++) {
      g.fillEllipse(Math.random()*600, Math.random()*600, 80+Math.random()*80, 50+Math.random()*50);
    }
    // subtle border
    g.lineStyle(3, 0x9a8f7a, 0.4);
    g.strokeRectShape({ x: 8, y: 8, width: 584, height: 584 } as any);
    this.finish(g, 'bg-marble', 'marble');
  }

  // ── 6. Funny Dinosaur (cartoon T-Rex) ──
  private generateDino(): void {
    const g = this.scene.make.graphics({ x: 0, y: 0 }, false);
    // pastel sky
    g.fillStyle(0xaee1f9, 1);
    g.fillRect(0, 0, 600, 600);
    // sun
    g.fillStyle(0xffe066, 1);
    g.fillCircle(530, 70, 40);
    // clouds
    g.fillStyle(0xffffff, 0.95);
    g.fillEllipse(90, 90, 90, 30);
    g.fillEllipse(120, 80, 60, 26);
    g.fillEllipse(320, 120, 100, 30);
    g.fillEllipse(350, 110, 60, 24);
    // ground
    g.fillStyle(0x9ade5b, 1);
    g.fillRect(0, 470, 600, 130);
    g.fillStyle(0x7cc24a, 1);
    g.fillRect(0, 480, 600, 8);

    // ── Funny T-Rex body (fat lime green) ──
    const dinoGreen = 0x71c837;
    const dinoDark = 0x4f9a24;
    g.fillStyle(dinoGreen, 1);
    // tail (triangles pointing up-right)
    g.fillTriangle(120, 360, 200, 290, 210, 380);
    // body (large ellipse)
    g.fillEllipse(260, 360, 200, 130);
    // belly
    g.fillStyle(0xd9f5a3, 1);
    g.fillEllipse(280, 380, 130, 80);
    // head (circle top-right of body)
    g.fillStyle(dinoGreen, 1);
    g.fillCircle(380, 300, 62);
    // mouth / open jaw
    g.fillStyle(0xffffff, 1);
    g.fillRect(395, 318, 52, 14);
    g.fillStyle(0x3a3a3a, 1);
    g.fillRect(395, 318, 52, 12);
    // teeth
    g.fillStyle(0xffffff, 1);
    for (let i = 0; i < 5; i++) {
      g.fillTriangle(400 + i * 10, 318, 405 + i * 10, 318, 402 + i * 10, 308);
    }
    // eye (big, funny)
    g.fillStyle(0xffffff, 1);
    g.fillCircle(392, 278, 20);
    g.fillStyle(0x222222, 1);
    g.fillCircle(398, 276, 9);
    g.fillStyle(0xffffff, 1);
    g.fillCircle(402, 272, 3);
    // tiny arms
    g.lineStyle(12, dinoGreen, 1);
    g.lineBetween(360, 380, 350, 415);
    g.lineBetween(280, 400, 270, 430);
    g.lineStyle(12, dinoDark, 1);
    g.lineBetween(350, 415, 340, 412);
    g.lineBetween(270, 430, 260, 427);
    g.lineStyle(0, 0);
    // nostrils
    g.fillStyle(0x2f5d14, 1);
    g.fillCircle(410, 300, 3);
    g.fillCircle(418, 298, 3);

    // feet (two fat legs)
    g.fillStyle(dinoGreen, 1);
    g.fillCircle(240, 455, 24);
    g.fillCircle(320, 455, 24);
    g.fillStyle(dinoDark, 1);
    g.fillCircle(232, 468, 16);
    g.fillCircle(328, 468, 16);

    // small flower props for charm
    g.fillStyle(0xff66cc, 1);
    g.fillCircle(90, 500, 7);
    g.fillCircle(500, 520, 7);
    g.fillCircle(300, 540, 7);

    this.finish(g, 'bg-dino', 'dino');
  }

  private finish(g: Phaser.GameObjects.Graphics, key: string, id: string): void {
    g.generateTexture(key, 600, 600);
    g.destroy();
    this.defaultTextureKeys[id] = key;
  }
}

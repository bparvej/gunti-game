export interface Theme {
  name: string;
  backgroundColor: string;
  backgroundImage?: string;
  boardLineColor: number;
  redColor: number;
  blueColor: number;
  textColor: string;
  hintNormalColor: number;
  hintCaptureColor: number;
}

export class ThemeManager {
  private currentThemeIndex: number = 0;

  private themes: Theme[] = [
    {
      name: 'Classic Light',
      backgroundColor: '#ffffff',
      boardLineColor: 0x000000,
      redColor: 0xff0000,
      blueColor: 0x0000ff,
      textColor: '#000000',
      hintNormalColor: 0x00ff00,
      hintCaptureColor: 0xffaa00,
    },
    {
      name: 'Dark Mode',
      backgroundColor: '#1a1a1a',
      boardLineColor: 0xffffff,
      redColor: 0xff4444,
      blueColor: 0x4444ff,
      textColor: '#ffffff',
      hintNormalColor: 0x44ff44,
      hintCaptureColor: 0xffcc44,
    },
    {
      name: 'Ocean Blue',
      backgroundColor: '#e0f2f1',
      boardLineColor: 0x00695c,
      redColor: 0xff5252,
      blueColor: 0x1976d2,
      textColor: '#004d40',
      hintNormalColor: 0x26c6da,
      hintCaptureColor: 0xffa726,
    },
    {
      name: 'Sunset Gold',
      backgroundColor: '#fff8e1',
      boardLineColor: 0xf57f17,
      redColor: 0xe53935,
      blueColor: 0xfb8c00,
      textColor: '#bf360c',
      hintNormalColor: 0x9ccc65,
      hintCaptureColor: 0xffa726,
    },
    {
      name: 'Purple Dream',
      backgroundColor: '#f3e5f5',
      boardLineColor: 0x4a148c,
      redColor: 0xd32f2f,
      blueColor: 0x7b1fa2,
      textColor: '#4a148c',
      hintNormalColor: 0x00bcd4,
      hintCaptureColor: 0xffca28,
    },
  ];

  getCurrentTheme(): Theme {
    return this.themes[this.currentThemeIndex];
  }

  nextTheme(): Theme {
    this.currentThemeIndex = (this.currentThemeIndex + 1) % this.themes.length;
    return this.getCurrentTheme();
  }

  getThemeByName(name: string): Theme | undefined {
    return this.themes.find(t => t.name === name);
  }

  getAllThemes(): Theme[] {
    return this.themes;
  }

  getThemeName(): string {
    return this.getCurrentTheme().name;
  }
}

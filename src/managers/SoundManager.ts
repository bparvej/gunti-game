import Phaser from 'phaser';

export class SoundManager {
  private scene: Phaser.Scene;
  private soundEnabled: boolean = true;

  constructor(scene: Phaser.Scene) {
    this.scene = scene;
  }

  // Create simple beep sounds using Web Audio API
  playMoveSound(): void {
    if (!this.soundEnabled) return;
    this.playBeep(400, 100);
  }

  playCaptureSound(): void {
    if (!this.soundEnabled) return;
    this.playBeep(600, 150);
  }

  playWinSound(): void {
    if (!this.soundEnabled) return;
    this.playBeep(800, 200);
    setTimeout(() => this.playBeep(1000, 200), 150);
  }

  playErrorSound(): void {
    if (!this.soundEnabled) return;
    this.playBeep(300, 100);
  }

  playSlideSound(): void {
    if (!this.soundEnabled) return;
    this.playSlideWhoosh(300);
  }

  playYooSound(): void {
    if (!this.soundEnabled) return;
    this.playYooCelebration();
  }

  private playBeep(frequency: number, duration: number): void {
    try {
      const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
      const oscillator = audioContext.createOscillator();
      const gainNode = audioContext.createGain();

      oscillator.connect(gainNode);
      gainNode.connect(audioContext.destination);

      oscillator.frequency.value = frequency;
      oscillator.type = 'sine';

      gainNode.gain.setValueAtTime(0.1, audioContext.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + duration / 1000);

      oscillator.start(audioContext.currentTime);
      oscillator.stop(audioContext.currentTime + duration / 1000);
    } catch (e) {
      console.log('Web Audio API not available');
    }
  }

  private playSlideWhoosh(duration: number): void {
    try {
      const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
      
      // Create noise buffer for "sshhhh" effect
      const bufferSize = audioContext.sampleRate * (duration / 1000);
      const noiseBuffer = audioContext.createBuffer(1, bufferSize, audioContext.sampleRate);
      const output = noiseBuffer.getChannelData(0);
      
      for (let i = 0; i < bufferSize; i++) {
        output[i] = Math.random() * 2 - 1;
      }
      
      const noiseSource = audioContext.createBufferSource();
      noiseSource.buffer = noiseBuffer;
      
      // Create gain node for volume envelope
      const gainNode = audioContext.createGain();
      
      // Create high-pass filter for "whoosh" effect
      const filter = audioContext.createBiquadFilter();
      filter.type = 'highpass';
      filter.frequency.value = 2000;
      
      noiseSource.connect(filter);
      filter.connect(gainNode);
      gainNode.connect(audioContext.destination);
      
      // Fade in quickly and fade out over duration
      gainNode.gain.setValueAtTime(0, audioContext.currentTime);
      gainNode.gain.linearRampToValueAtTime(0.15, audioContext.currentTime + 0.05);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + duration / 1000);
      
      noiseSource.start(audioContext.currentTime);
      noiseSource.stop(audioContext.currentTime + duration / 1000);
    } catch (e) {
      console.log('Web Audio API not available for slide sound');
    }
  }

  private playYooCelebration(): void {
    try {
      const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
      const now = audioContext.currentTime;

      // Create "Yoo" with two tones: high note down to lower note
      const frequencies = [600, 550, 500]; // descending pitch for celebratory "Yoo"
      let delay = 0;

      frequencies.forEach((freq, idx) => {
        const osc = audioContext.createOscillator();
        const gain = audioContext.createGain();

        osc.connect(gain);
        gain.connect(audioContext.destination);

        osc.frequency.value = freq;
        osc.type = 'sine';

        const start = now + delay;
        const duration = 0.15;

        gain.gain.setValueAtTime(0.2, start);
        gain.gain.exponentialRampToValueAtTime(0.01, start + duration);

        osc.start(start);
        osc.stop(start + duration);

        delay += 0.1;
      });
    } catch (e) {
      console.log('Web Audio API not available for yoo sound');
    }
  }

  toggleSound(): void {
    this.soundEnabled = !this.soundEnabled;
  }

  isSoundEnabled(): boolean {
    return this.soundEnabled;
  }
}

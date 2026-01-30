export interface GameStats {
  redWins: number;
  blueWins: number;
  totalGames: number;
  movesInLastGame: number;
  averageMoves: number;
  lastWinner?: 'RED' | 'BLUE';
}

export class StatsManager {
  private stats: GameStats = {
    redWins: 0,
    blueWins: 0,
    totalGames: 0,
    movesInLastGame: 0,
    averageMoves: 0,
  };

  private storageKey = 'gunti-game-stats';

  constructor() {
    this.loadStats();
  }

  recordWin(winner: 'RED' | 'BLUE', moves: number): void {
    if (winner === 'RED') {
      this.stats.redWins++;
    } else {
      this.stats.blueWins++;
    }
    this.stats.totalGames++;
    this.stats.movesInLastGame = moves;
    this.stats.lastWinner = winner;
    this.updateAverageMoves(moves);
    this.saveStats();
  }

  private updateAverageMoves(newMoves: number): void {
    const totalMoves = (this.stats.averageMoves * (this.stats.totalGames - 1)) + newMoves;
    this.stats.averageMoves = Math.round(totalMoves / this.stats.totalGames);
  }

  getStats(): GameStats {
    return { ...this.stats };
  }

  resetStats(): void {
    this.stats = {
      redWins: 0,
      blueWins: 0,
      totalGames: 0,
      movesInLastGame: 0,
      averageMoves: 0,
    };
    this.saveStats();
  }

  private saveStats(): void {
    try {
      localStorage.setItem(this.storageKey, JSON.stringify(this.stats));
    } catch (e) {
      console.log('Could not save stats to localStorage');
    }
  }

  private loadStats(): void {
    try {
      const stored = localStorage.getItem(this.storageKey);
      if (stored) {
        this.stats = JSON.parse(stored);
      }
    } catch (e) {
      console.log('Could not load stats from localStorage');
    }
  }
}

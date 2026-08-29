import { NodeKey } from '../board/Nodes';
import { Player } from '../guti/Guti';

export interface Move {
  player: Player;
  from: NodeKey;
  to: NodeKey;
  moveNumber: number;
}

export class MoveHistoryManager {
  private moves: Move[] = [];
  private moveNumber: number = 1;

  recordMove(player: Player, from: NodeKey, to: NodeKey): void {
    this.moves.push({
      player,
      from,
      to,
      moveNumber: this.moveNumber,
    });
    this.moveNumber++;
  }

  undoLastMove(): Move | null {
    if (this.moves.length === 0) return null;
    const lastMove = this.moves.pop();
    if (lastMove) {
      this.moveNumber--;
    }
    return lastMove || null;
  }

  getMoves(): Move[] {
    return [...this.moves];
  }

  getLastMove(): Move | null {
    return this.moves.length > 0 ? this.moves[this.moves.length - 1] : null;
  }

  reset(): void {
    this.moves = [];
    this.moveNumber = 1;
  }

  getMoveCount(): number {
    return this.moves.length;
  }

  getFormattedHistory(): string {
    return this.moves
      .map(m => `Move ${m.moveNumber}: ${m.player} from ${m.from} to ${m.to}`)
      .join('\n');
  }
}

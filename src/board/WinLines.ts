import { NodeKey } from './Nodes';

export const WIN_LINES: NodeKey[][] = [
  // Vertical
  ['T','C','B'],
  ['TL','L','BL'],
  ['TR','R','BR'],

  // Horizontal
  ['L','C','R'],
  ['TL','T','TR'],
  ['BL','B','BR'],

  // Diagonals
  ['TL','C','BR'],
  ['TR','C','BL']
];

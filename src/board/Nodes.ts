export type NodeKey =
  | 'T' | 'B' | 'L' | 'R'
  | 'TL' | 'TR' | 'BL' | 'BR'
  | 'C';

export interface Node {
  x: number;
  y: number;
  links: NodeKey[];
}

export const NODES: Record<NodeKey, Node> = {
  C:  { x: 300, y: 300, links: ['T','B','L','R','TL','TR','BL','BR'] },

  T:  { x: 300, y: 100, links: ['C','TL','TR'] },
  B:  { x: 300, y: 500, links: ['C','BL','BR'] },
  L:  { x: 100, y: 300, links: ['C','TL','BL'] },
  R:  { x: 500, y: 300, links: ['C','TR','BR'] },

  TL: { x: 100, y: 100, links: ['T','L','C'] },
  TR: { x: 500, y: 100, links: ['T','R','C'] },
  BL: { x: 100, y: 500, links: ['B','L','C'] },
  BR: { x: 500, y: 500, links: ['B','R','C'] }
};

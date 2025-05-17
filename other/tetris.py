#!/usr/bin/env python3
"""Simple Tetris clone using curses.

This script implements a minimal Tetris game that runs in the terminal using
:mod:`curses`. Use the arrow keys to move the piece, up arrow to rotate and
``q`` to quit the game.
"""

from __future__ import annotations

import curses
import random
from dataclasses import dataclass
from typing import List, Tuple

BOARD_WIDTH = 10
BOARD_HEIGHT = 20

# Each shape contains a list of rotations and each rotation is a list of
# (x, y) offsets for the four blocks.
SHAPES: List[List[List[Tuple[int, int]]]] = [
    # I shape
    [
        [(0, 1), (1, 1), (2, 1), (3, 1)],
        [(2, 0), (2, 1), (2, 2), (2, 3)],
    ],
    # J shape
    [
        [(0, 0), (0, 1), (1, 1), (2, 1)],
        [(1, 0), (2, 0), (1, 1), (1, 2)],
        [(0, 1), (1, 1), (2, 1), (2, 2)],
        [(1, 0), (1, 1), (0, 2), (1, 2)],
    ],
    # L shape
    [
        [(2, 0), (0, 1), (1, 1), (2, 1)],
        [(1, 0), (1, 1), (1, 2), (2, 2)],
        [(0, 1), (1, 1), (2, 1), (0, 2)],
        [(0, 0), (1, 0), (1, 1), (1, 2)],
    ],
    # O shape
    [
        [(1, 0), (2, 0), (1, 1), (2, 1)],
    ],
    # S shape
    [
        [(1, 1), (2, 1), (0, 2), (1, 2)],
        [(1, 0), (1, 1), (2, 1), (2, 2)],
    ],
    # T shape
    [
        [(1, 0), (0, 1), (1, 1), (2, 1)],
        [(1, 0), (1, 1), (2, 1), (1, 2)],
        [(0, 1), (1, 1), (2, 1), (1, 2)],
        [(1, 0), (0, 1), (1, 1), (1, 2)],
    ],
    # Z shape
    [
        [(0, 1), (1, 1), (1, 2), (2, 2)],
        [(2, 0), (1, 1), (2, 1), (1, 2)],
    ],
]


@dataclass
class Piece:
    shape: List[List[Tuple[int, int]]]
    x: int = 3
    y: int = 0
    rotation: int = 0

    @property
    def blocks(self) -> List[Tuple[int, int]]:
        return [
            (self.x + dx, self.y + dy) for dx, dy in self.shape[self.rotation]
        ]

    def rotate(self) -> None:
        self.rotation = (self.rotation + 1) % len(self.shape)


def create_piece() -> Piece:
    return Piece(random.choice(SHAPES))


def collision(board: List[List[int]], piece: Piece, dx: int = 0, dy: int = 0, rotation: bool = False) -> bool:
    new_rot = (piece.rotation + 1) % len(piece.shape) if rotation else piece.rotation
    for px, py in [
        (piece.x + dx + x, piece.y + dy + y)
        for x, y in piece.shape[new_rot]
    ]:
        if px < 0 or px >= BOARD_WIDTH or py < 0 or py >= BOARD_HEIGHT:
            return True
        if board[py][px]:
            return True
    return False


def merge_piece(board: List[List[int]], piece: Piece) -> None:
    for px, py in piece.blocks:
        board[py][px] = 1


def clear_lines(board: List[List[int]]) -> int:
    cleared = 0
    new_board = [row for row in board if any(cell == 0 for cell in row)]
    cleared = BOARD_HEIGHT - len(new_board)
    while len(new_board) < BOARD_HEIGHT:
        new_board.insert(0, [0] * BOARD_WIDTH)
    board[:] = new_board
    return cleared


def draw(stdscr: curses.window, board: List[List[int]], piece: Piece) -> None:
    stdscr.clear()
    for y, row in enumerate(board):
        for x, val in enumerate(row):
            char = "[]" if val else " ."
            stdscr.addstr(y, x * 2, char)
    for x, y in piece.blocks:
        if 0 <= y < BOARD_HEIGHT:
            stdscr.addstr(y, x * 2, "[]")
    stdscr.refresh()


def game(stdscr: curses.window) -> None:
    curses.curs_set(0)
    stdscr.nodelay(True)
    stdscr.timeout(300)

    board = [[0] * BOARD_WIDTH for _ in range(BOARD_HEIGHT)]
    current = create_piece()

    while True:
        draw(stdscr, board, current)
        key = stdscr.getch()
        if key == curses.KEY_LEFT and not collision(board, current, dx=-1):
            current.x -= 1
        elif key == curses.KEY_RIGHT and not collision(board, current, dx=1):
            current.x += 1
        elif key == curses.KEY_DOWN and not collision(board, current, dy=1):
            current.y += 1
        elif key == curses.KEY_UP and not collision(board, current, rotation=True):
            current.rotate()
        elif key in (ord("q"), ord("Q")):
            break

        if collision(board, current, dy=1):
            merge_piece(board, current)
            clear_lines(board)
            current = create_piece()
            if collision(board, current):
                stdscr.addstr(BOARD_HEIGHT // 2, 0, "Game Over! Press any key")
                stdscr.nodelay(False)
                stdscr.getch()
                break
        else:
            current.y += 1


def main() -> None:
    curses.wrapper(game)


if __name__ == "__main__":
    main()

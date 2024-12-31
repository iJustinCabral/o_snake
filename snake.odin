// Classic Snake Game
package game

import    "core:fmt"
import rl "vendor:raylib"

WINDOW_SIZE :: 1000
GRID_SIZE   :: 20
CELL_SIZE   :: 16

main :: proc() {
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "O-Snake")
    defer rl.CloseWindow()

    for !rl.WindowShouldClose() {
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground(rl.BLACK)

    }

}



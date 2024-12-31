// Classic Snake Game
package game

import    "core:fmt"
import    "core:math/rand"
import rl "vendor:raylib"

// Constants
WINDOW_SIZE   :: 1000
GRID_WIDTH    :: 20
CELL_SIZE     :: 16
CANVAS_SIZE   :: GRID_WIDTH * CELL_SIZE
TICK_RATE     :: 0.13
MAX_SIZE      :: GRID_WIDTH * GRID_WIDTH

// Type & variable defintions
Vector2Int     :: [2]int
tick_timer     : f32 = TICK_RATE
snake	       : [MAX_SIZE]Vector2Int
snake_length   : int
move_direction : Vector2Int
game_over      : bool = false 
food_pos       : Vector2Int
crash_sound    : rl.Sound
eat_sound      : rl.Sound

main :: proc() {
    rl.InitWindow(WINDOW_SIZE, WINDOW_SIZE, "O-Snake")
    defer rl.CloseWindow()

    rl.InitAudioDevice()
    defer rl.CloseAudioDevice()

    crash_sound = rl.LoadSound("crash.wav")
    eat_sound   = rl.LoadSound("eat.wav")

    restart()

    // Set camera
    camera := rl.Camera2D {
	zoom = f32(WINDOW_SIZE) / CANVAS_SIZE
    }

    for !rl.WindowShouldClose() {
	
	// Handle Input
	if rl.IsKeyDown(.UP) || rl.IsKeyDown(.W) && move_direction != {0, 1} {
	    move_direction = {0, -1}
	}
	if rl.IsKeyDown(.DOWN) || rl.IsKeyDown(.S) && move_direction != {0, -1} {
	    move_direction = {0, 1}
	}
	if rl.IsKeyDown(.LEFT) || rl.IsKeyDown(.A) && move_direction != {1, 0} {
	    move_direction = {-1, 0}
	}
	if rl.IsKeyDown(.RIGHT) || rl.IsKeyDown(.D) && move_direction != {-1, 0} {
	    move_direction = {1, 0}
	}

	// Updates 
	if game_over {
	    if rl.IsKeyPressed(.ENTER) || rl.IsKeyPressed(.SPACE) {
		restart()
	    }
	} else {
	    tick_timer -= rl.GetFrameTime()
	}

	if tick_timer <= 0 {
	    next_part_pos := snake[0]
	    snake[0] += move_direction
	    head_pos := snake[0]

	    if head_pos.x < 0 || head_pos.y < 0 || head_pos.x >= GRID_WIDTH || head_pos.y >= GRID_WIDTH {
		rl.PlaySound(crash_sound)
		game_over = true
	    }

	    for i in 1..<snake_length {
		cur_pos := snake[i]

		if cur_pos == head_pos {
		    rl.PlaySound(crash_sound)
		    game_over = true
		}

		snake[i]= next_part_pos
		next_part_pos = cur_pos
	    }

	    if head_pos == food_pos {
		snake_length += 1
		snake[snake_length - 1] = next_part_pos
		rl.PlaySound(eat_sound)
		place_food()
	    }

	    tick_timer = TICK_RATE + tick_timer
	}

	// Draw
	rl.BeginDrawing()
	defer rl.EndDrawing()

	rl.ClearBackground({0x1C, 0x18, 0x52, 0xFF})

	rl.BeginMode2D(camera)
	defer rl.EndMode2D()

	draw_food()
	draw_snake()
	draw_game_over()
	draw_score()

	defer free_all(context.temp_allocator)
    }

}

restart :: proc() {
    start_head_pos := Vector2Int{ GRID_WIDTH / 2, GRID_WIDTH / 2}
    snake[0] = start_head_pos
    snake[1] = start_head_pos - {0, 1}
    snake[2] = start_head_pos - {0, 2}
    snake_length = 3
    move_direction = {0, 1}
    game_over = false
    place_food()
}

place_food :: proc() {
    occupied : [GRID_WIDTH][GRID_WIDTH]bool

    for i in 0..<snake_length {
	occupied[snake[i].x][snake[i].y] = true 
    }

    free_cells := make([dynamic]Vector2Int, context.temp_allocator)
    for x in 0..<GRID_WIDTH {
	for y in 0..<GRID_WIDTH {
	    if !occupied[x][y] {
		append(&free_cells, Vector2Int{x,x})
	    }
	}
    }

    if len(free_cells) > 0 {
	random_cell_index := rl.GetRandomValue(0, i32(len(free_cells) - 1))
	food_pos = free_cells[random_cell_index]
    }
}

draw_snake :: proc() {

    for i in 0..<snake_length {
      part_rect := rl.Rectangle {
	    f32(snake[i].x) * CELL_SIZE,
	    f32(snake[i].y) * CELL_SIZE,
	    CELL_SIZE,
	    CELL_SIZE,
	}

	rl.DrawRectangleRec(part_rect, rl.GREEN)
    }
}

draw_food :: proc() {
    food_rect := rl.Rectangle {
	f32(food_pos.x) * CELL_SIZE,
	f32(food_pos.y) * CELL_SIZE,
	CELL_SIZE,
	CELL_SIZE,
    }

    rl.DrawRectangleRec(food_rect, {0xC7, 0x49, 0x95, 0xFF})
}

draw_score :: proc() {
    score := snake_length - 3
    score_str := fmt.ctprintf("Score: %v", score)
    rl.DrawText(score_str, 4, CANVAS_SIZE - 14, 10, rl.WHITE)
}

draw_game_over :: proc() {
    if game_over {
	rl.DrawText("Game Over!", 4, 4, 24, rl.RED)
	rl.DrawText("Press Enter/Space to restart", 4, 30, 18, rl.WHITE)
    }
}



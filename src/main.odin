package undeads

import rl "vendor:raylib"

PLAYER_COUNT :: 2

Player :: struct {
	using entity:   Entity,
	camera:         rl.Camera,
	render_texture: rl.RenderTexture,
	color:          rl.Color,
}

Entity :: struct {
	transform: Transform,
}

Transform :: struct {
	position: Vec3,
	rotation: Vec3,
	scale:    Vec3,
}

Vec3 :: [3]f32

draw_scene :: proc(players: ^[PLAYER_COUNT]Player) {
	rl.DrawGrid(10, 1)

	for player in players {
		rl.DrawCubeV(player.transform.position, player.transform.scale, player.color)
		rl.DrawCubeWiresV(player.transform.position, player.transform.scale, rl.BLACK)
	}
}

main :: proc() {
	rl.SetConfigFlags({.VSYNC_HINT, .MSAA_4X_HINT})
	rl.InitWindow(1280, 720, "Undead")

	players: [PLAYER_COUNT]Player

	for &player, index in players {
		player = {
			transform = {position = {f32(index) * 2, 0.5, 0}, scale = 1},
			camera = {
				position = {0, 1, 0},
				target = {0.185, 0.4, 0},
				up = {0, 1, 0},
				fovy = 45,
				projection = .PERSPECTIVE,
			},
			render_texture = rl.LoadRenderTexture(
				rl.GetScreenWidth(),
				rl.GetScreenHeight() / PLAYER_COUNT,
			),
			color = index == 0 ? rl.GREEN : rl.RED,
		}
	}

	rl.DisableCursor()
	source_rect := rl.Rectangle {
		0,
		0,
		f32(players[0].render_texture.texture.width),
		-f32(players[0].render_texture.texture.height),
	}

	for !rl.WindowShouldClose() {
		if rl.IsWindowResized() {
			width := rl.GetScreenWidth()
			height := rl.GetScreenHeight()

			for &player in players {
				rl.UnloadRenderTexture(player.render_texture)
				player.render_texture = rl.LoadRenderTexture(width, height / PLAYER_COUNT)
				source_rect = {0, 0, f32(width), -f32(height / PLAYER_COUNT)}
			}
		}

		if rl.IsKeyDown(.SPACE) {
			rl.UpdateCamera(&players[0].camera, .FIRST_PERSON)
		} else {
			rl.UpdateCamera(&players[1].camera, .FIRST_PERSON)
		}

		for &player in players {
			player.transform.position = player.camera.position - {0, 0.5, 0}
		}
		// DRAW PLAYER VIEW

		for &player in players {
			rl.BeginTextureMode(player.render_texture)
			rl.ClearBackground(rl.DARKBLUE)
			rl.BeginMode3D(player.camera)
			draw_scene(&players)
			rl.EndMode3D()
			rl.EndTextureMode()
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		for &player, index in players {
			y_pos := (f32(rl.GetScreenHeight()) / f32(PLAYER_COUNT)) * f32(index)

			dest_rect := rl.Rectangle {
				0,
				y_pos,
				f32(rl.GetScreenWidth()),
				f32(rl.GetScreenHeight()) / f32(PLAYER_COUNT),
			}

			rl.DrawTexturePro(
				player.render_texture.texture,
				source_rect,
				dest_rect,
				{0, 0},
				0,
				rl.WHITE,
			)

		}

		rl.DrawFPS(10, 10)
		rl.EndDrawing()
	}

  for player in players {
    rl.UnloadRenderTexture(player.render_texture)
  }
	rl.CloseWindow()
}

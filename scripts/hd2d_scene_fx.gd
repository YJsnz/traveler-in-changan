extends Control

const WORLD_WIDTH := 2400.0

var t := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(WORLD_WIDTH, 720)

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _draw() -> void:
	_draw_depth_blur_bands()
	_draw_lantern_haze()
	_draw_rain()
	_draw_ground_sheen()
	_draw_dust()
	_draw_foreground_depth()
	_draw_vignette()

func _draw_lantern_haze() -> void:
	var lanterns := [Vector2(258, 320), Vector2(650, 332), Vector2(962, 326), Vector2(1350, 404), Vector2(1760, 404), Vector2(2150, 400)]
	for pos in lanterns:
		draw_rect(Rect2(pos - Vector2(86, 24), Vector2(172, 48)), Color(0.95, 0.54, 0.18, 0.055))
		draw_rect(Rect2(pos - Vector2(54, 12), Vector2(108, 24)), Color(1.0, 0.68, 0.25, 0.070))
		draw_line(pos + Vector2(-22, 2), pos + Vector2(-70, 210), Color(0.93, 0.62, 0.25, 0.035), 2.0)
		draw_line(pos + Vector2(22, 2), pos + Vector2(70, 210), Color(0.93, 0.62, 0.25, 0.035), 2.0)

func _draw_depth_blur_bands() -> void:
	draw_rect(Rect2(Vector2(0, 150), Vector2(WORLD_WIDTH, 86)), Color(0.68, 0.76, 0.82, 0.014))
	draw_rect(Rect2(Vector2(0, 0), Vector2(WORLD_WIDTH, 96)), Color(0.74, 0.86, 0.96, 0.018))
	draw_rect(Rect2(Vector2(0, 616), Vector2(WORLD_WIDTH, 104)), Color(0, 0, 0, 0.10))

func _draw_rain() -> void:
	for i in range(76):
		var base_x := fmod(float(i * 73) + t * 95.0, WORLD_WIDTH)
		var base_y := fmod(float(120 + (i * 41) % 560) + t * 165.0, 620.0)
		var start := Vector2(base_x, base_y)
		draw_line(start, start + Vector2(-6, 23), Color(0.65, 0.78, 0.88, 0.13), 1.0)

func _draw_ground_sheen() -> void:
	for i in range(13):
		var x := 100.0 + i * 165.0 + sin(t * 0.8 + i) * 8.0
		draw_rect(Rect2(Vector2(x, 603 + (i % 3) * 22), Vector2(78, 2)), Color(0.86, 0.68, 0.42, 0.10))
		draw_rect(Rect2(Vector2(x + 34, 640 + (i % 2) * 18), Vector2(120, 2)), Color(0.45, 0.58, 0.60, 0.07))

func _draw_dust() -> void:
	for i in range(22):
		var x := 120.0 + fmod(i * 101.0 + t * (8.0 + i), WORLD_WIDTH - 240.0)
		var y := 335.0 + sin(t * 0.7 + i * 1.9) * 18.0 + (i % 4) * 18.0
		draw_rect(Rect2(Vector2(x, y), Vector2(3, 3)), Color(1.0, 0.72, 0.34, 0.08))

func _draw_foreground_depth() -> void:
	draw_rect(Rect2(Vector2(0, 520), Vector2(WORLD_WIDTH, 16)), Color(0, 0, 0, 0.05))
	draw_rect(Rect2(Vector2(0, 584), Vector2(WORLD_WIDTH, 12)), Color(0.12, 0.10, 0.09, 0.06))
	draw_rect(Rect2(Vector2(42, 560), Vector2(62, 112)), Color(0.05, 0.04, 0.04, 0.08))
	draw_rect(Rect2(Vector2(1180, 548), Vector2(76, 124)), Color(0.05, 0.04, 0.04, 0.08))
	for i in range(8):
		var x := 220.0 + i * 260.0
		draw_line(Vector2(x, 250), Vector2(x - 24, 520), Color(0.08, 0.07, 0.08, 0.13), 3.0)
	draw_rect(Rect2(Vector2(0, 650), Vector2(WORLD_WIDTH, 70)), Color(0.04, 0.035, 0.03, 0.10))
	for i in range(14):
		var x := 84.0 + i * 118.0
		draw_rect(Rect2(Vector2(x, 650 + (i % 2) * 12), Vector2(58, 48)), Color(0.24, 0.20, 0.16, 0.28))

func _draw_vignette() -> void:
	draw_rect(Rect2(Vector2(0, 0), Vector2(WORLD_WIDTH, 54)), Color(0, 0, 0, 0.22))
	draw_rect(Rect2(Vector2(0, 0), Vector2(44, 720)), Color(0, 0, 0, 0.18))
	draw_rect(Rect2(Vector2(WORLD_WIDTH - 44.0, 0), Vector2(44, 720)), Color(0, 0, 0, 0.18))
	draw_rect(Rect2(Vector2(0, 672), Vector2(WORLD_WIDTH, 48)), Color(0, 0, 0, 0.24))

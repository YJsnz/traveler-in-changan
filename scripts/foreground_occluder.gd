extends Control

const WORLD_SIZE := Vector2(2400, 720)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = WORLD_SIZE

func _draw() -> void:
	_draw_market_foreground()
	_draw_bottom_depth()

func _draw_market_foreground() -> void:
	draw_rect(Rect2(Vector2(0, 604), Vector2(WORLD_SIZE.x, 16)), Color(0.05, 0.045, 0.04, 0.22))
	for i in range(27):
		var x := 36.0 + i * 84.0
		draw_rect(Rect2(Vector2(x, 586 + (i % 2) * 5), Vector2(30, 34)), Color(0.25, 0.22, 0.18, 0.34))
		draw_rect(Rect2(Vector2(x + 4, 590 + (i % 2) * 5), Vector2(22, 8)), Color(0.54, 0.48, 0.38, 0.22))
	draw_rect(Rect2(Vector2(18, 505), Vector2(94, 100)), Color(0.03, 0.025, 0.02, 0.18))
	draw_rect(Rect2(Vector2(1134, 500), Vector2(118, 108)), Color(0.03, 0.025, 0.02, 0.18))
	draw_rect(Rect2(Vector2(414, 560), Vector2(52, 28)), Color(0.28, 0.22, 0.16, 0.28))
	draw_rect(Rect2(Vector2(724, 560), Vector2(54, 30)), Color(0.28, 0.22, 0.16, 0.24))
	draw_rect(Rect2(Vector2(1028, 552), Vector2(70, 38)), Color(0.23, 0.18, 0.15, 0.26))
	draw_rect(Rect2(Vector2(1320, 548), Vector2(72, 40)), Color(0.23, 0.18, 0.15, 0.22))
	draw_rect(Rect2(Vector2(1736, 552), Vector2(76, 40)), Color(0.18, 0.14, 0.12, 0.26))
	draw_rect(Rect2(Vector2(2188, 530), Vector2(90, 58)), Color(0.08, 0.06, 0.05, 0.26))

func _draw_bottom_depth() -> void:
	draw_rect(Rect2(Vector2(0, 652), Vector2(WORLD_SIZE.x, 68)), Color(0, 0, 0, 0.24))
	draw_rect(Rect2(Vector2(0, 690), Vector2(WORLD_SIZE.x, 30)), Color(0, 0, 0, 0.26))

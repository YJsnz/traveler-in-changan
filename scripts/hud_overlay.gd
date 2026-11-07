extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)

func _draw() -> void:
	_draw_location_plate()
	_draw_minimap()

func _draw_location_plate() -> void:
	var origin := Vector2(28, 646)
	draw_circle(origin + Vector2(48, 48), 43, Color(0.02, 0.02, 0.025, 0.45))
	draw_arc(origin + Vector2(48, 48), 43, 0, TAU, 48, Color(0.75, 0.75, 0.70, 0.35), 2.0)
	draw_line(origin + Vector2(100, 36), origin + Vector2(430, 36), Color(0.85, 0.85, 0.80, 0.36), 1.0)
	draw_string(ThemeDB.fallback_font, origin + Vector2(104, 22), "长安地区", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.82, 0.82, 0.78, 0.90))
	draw_string(ThemeDB.fallback_font, origin + Vector2(104, 52), "西市", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#f2e6cf"))
	draw_string(ThemeDB.fallback_font, origin + Vector2(104, 82), "命案现场    Lv. 01", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.82, 0.82, 0.78, 0.72))
	draw_line(origin + Vector2(32, 28), origin + Vector2(62, 72), Color(0.78, 0.78, 0.72, 0.30), 2.0)
	draw_line(origin + Vector2(62, 28), origin + Vector2(32, 72), Color(0.78, 0.78, 0.72, 0.30), 2.0)

func _draw_minimap() -> void:
	var center := Vector2(1184, 650)
	draw_circle(center, 49, Color(0.08, 0.08, 0.08, 0.56))
	draw_circle(center, 43, Color(0.55, 0.55, 0.50, 0.22))
	draw_arc(center, 49, 0, TAU, 56, Color(0.75, 0.75, 0.70, 0.32), 2.0)
	draw_line(center + Vector2(-26, -8), center + Vector2(27, 8), Color(0.78, 0.76, 0.67, 0.18), 3.0)
	draw_circle(center + Vector2(8, -2), 5, Color("#65e07a"))
	draw_circle(center + Vector2(8, -2), 2, Color("#e9ffe7"))
	draw_string(ThemeDB.fallback_font, center + Vector2(-54, 76), "线索 0/2", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.90, 0.86, 0.74, 0.85))

extends Control

var prompt_text := "E"
var t := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(42, 34)

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func _draw() -> void:
	var bob := sin(t * 5.0) * 2.0
	var key_rect := Rect2(Vector2(7, 2 + bob), Vector2(28, 22))
	draw_rect(key_rect.grow(2), Color(0.05, 0.05, 0.06, 0.78))
	draw_rect(key_rect, Color(0.92, 0.58, 0.20, 0.95))
	draw_rect(Rect2(key_rect.position + Vector2(2, 2), Vector2(24, 3)), Color(1.0, 0.82, 0.36, 0.55))
	draw_string(ThemeDB.fallback_font, key_rect.position + Vector2(9, 17), prompt_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#17120f"))
	draw_line(Vector2(21, 27 + bob), Vector2(16, 34 + bob), Color(0.92, 0.58, 0.20, 0.85), 2.0)
	draw_line(Vector2(21, 27 + bob), Vector2(26, 34 + bob), Color(0.92, 0.58, 0.20, 0.85), 2.0)

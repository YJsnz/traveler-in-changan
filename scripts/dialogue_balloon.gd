extends Control

var speaker := ""
var body := ""
var tail_x := 0.5

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = Vector2(360, 132)

func set_dialogue(new_speaker: String, new_body: String, new_tail_x := 0.5) -> void:
	speaker = new_speaker
	body = new_body
	tail_x = clamp(new_tail_x, 0.18, 0.82)
	queue_redraw()

func _draw() -> void:
	var box := Rect2(Vector2(18, 4), Vector2(size.x - 38, size.y - 38))
	var points := PackedVector2Array([
		box.position + Vector2(18, 0),
		box.position + Vector2(box.size.x - 18, 0),
		box.position + Vector2(box.size.x, 18),
		box.position + Vector2(box.size.x - 8, box.size.y - 14),
		box.position + Vector2(box.size.x * (tail_x + 0.04), box.size.y - 14),
		box.position + Vector2(box.size.x * tail_x, box.size.y + 22),
		box.position + Vector2(box.size.x * (tail_x - 0.04), box.size.y - 14),
		box.position + Vector2(14, box.size.y - 14),
		box.position + Vector2(0, 18),
	])
	draw_colored_polygon(points, Color(0.86, 0.80, 0.68, 0.94))
	for i in range(points.size()):
		draw_line(points[i], points[(i + 1) % points.size()], Color(0.18, 0.15, 0.12, 0.85), 2.0)
	draw_rect(Rect2(box.position + Vector2(18, 18), Vector2(box.size.x - 36, 1)), Color(1, 1, 1, 0.28))
	draw_string(ThemeDB.fallback_font, box.position + Vector2(24, 28), speaker, HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#3a2b22"))
	_draw_wrapped(body, box.position + Vector2(42, 60), box.size.x - 70)
	draw_rect(Rect2(box.position + Vector2(box.size.x - 35, box.size.y - 42), Vector2(8, 8)), Color(0.20, 0.18, 0.15, 0.85))

func _draw_wrapped(text: String, pos: Vector2, max_width: float) -> void:
	var line := ""
	var y := pos.y
	var font := ThemeDB.fallback_font
	for word in text.split(" "):
		var candidate := word if line == "" else line + " " + word
		if font.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x > max_width and line != "":
			draw_string(font, Vector2(pos.x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#3a2b22"))
			y += 25
			line = word
		else:
			line = candidate
	if line != "":
		draw_string(font, Vector2(pos.x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#3a2b22"))

extends Control

var variant := 0
var base_color := Color("#d9903d")
var accent_color := Color("#f2b34b")
var highlighted := false
var t := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	t += delta
	queue_redraw()

func setup(npc_variant: int, color: Color) -> void:
	variant = npc_variant
	base_color = color
	if variant == 0:
		accent_color = Color("#f0b24a")
	elif variant == 1:
		accent_color = Color("#b89952")
	else:
		accent_color = Color("#d9903d")
	queue_redraw()

func set_highlight(active: bool) -> void:
	highlighted = active
	queue_redraw()

func _draw() -> void:
	var sx := size.x / 52.0
	var sy := size.y / 80.0
	var bob := sin(t * 2.4 + float(variant)) * 0.7 * sy
	if highlighted:
		draw_rect(Rect2(Vector2(3 * sx, 67 * sy), Vector2(46 * sx, 8 * sy)), Color(0.95, 0.62, 0.18, 0.22))
		draw_rect(Rect2(Vector2(8 * sx, 70 * sy), Vector2(36 * sx, 3 * sy)), Color(1.0, 0.82, 0.36, 0.30))
	draw_rect(Rect2(Vector2(5 * sx, 69 * sy), Vector2(42 * sx, 6 * sy)), Color(0, 0, 0, 0.28))
	if variant == 0:
		_draw_vendor(sx, sy, bob)
	elif variant == 1:
		_draw_porter(sx, sy, bob)
	else:
		_draw_performer(sx, sy, bob)

func _draw_vendor(sx: float, sy: float, bob: float) -> void:
	_px(21 * sx, 10 * sy + bob, 14 * sx, 13 * sy, Color("#d2a272"))
	_px(18 * sx, 6 * sy + bob, 20 * sx, 8 * sy, Color("#5a3826"))
	_px(16 * sx, 27 * sy + bob, 25 * sx, 30 * sy, base_color)
	_px(13 * sx, 34 * sy + bob, 8 * sx, 22 * sy, Color("#7a4a25"))
	_px(38 * sx, 34 * sy + bob, 8 * sx, 22 * sy, Color("#7a4a25"))
	_px(17 * sx, 43 * sy + bob, 25 * sx, 4 * sy, accent_color)
	_px(18 * sx, 57 * sy + bob, 8 * sx, 14 * sy, Color("#151519"))
	_px(32 * sx, 57 * sy + bob, 8 * sx, 14 * sy, Color("#151519"))
	_px(7 * sx, 45 * sy + bob, 13 * sx, 11 * sy, Color("#8a5b2d"))
	_px(39 * sx, 45 * sy + bob, 12 * sx, 11 * sy, Color("#b57b35"))
	_px(26 * sx, 24 * sy + bob, 8 * sx, 3 * sy, Color("#f2d19b"))

func _draw_porter(sx: float, sy: float, bob: float) -> void:
	_px(20 * sx, 10 * sy + bob, 14 * sx, 13 * sy, Color("#d0a070"))
	_px(18 * sx, 7 * sy + bob, 18 * sx, 7 * sy, Color("#241b17"))
	_px(15 * sx, 27 * sy + bob, 24 * sx, 32 * sy, base_color)
	_px(10 * sx, 25 * sy + bob, 7 * sx, 36 * sy, Color("#554229"))
	_px(39 * sx, 25 * sy + bob, 7 * sx, 36 * sy, Color("#554229"))
	_px(13 * sx, 28 * sy + bob, 4 * sx, 36 * sy, Color("#332922"))
	_px(39 * sx, 28 * sy + bob, 4 * sx, 36 * sy, Color("#332922"))
	_px(17 * sx, 43 * sy + bob, 22 * sx, 4 * sy, accent_color)
	_px(18 * sx, 59 * sy + bob, 8 * sx, 13 * sy, Color("#14151a"))
	_px(31 * sx, 59 * sy + bob, 8 * sx, 13 * sy, Color("#14151a"))
	_px(23 * sx, 23 * sy + bob, 9 * sx, 3 * sy, Color("#f2d19b"))

func _draw_performer(sx: float, sy: float, bob: float) -> void:
	_px(21 * sx, 9 * sy + bob, 14 * sx, 14 * sy, Color("#d6a77b"))
	_px(18 * sx, 7 * sy + bob, 20 * sx, 7 * sy, Color("#28201c"))
	_px(16 * sx, 27 * sy + bob, 25 * sx, 32 * sy, base_color)
	_px(13 * sx, 32 * sy + bob, 8 * sx, 25 * sy, Color("#6c2a24"))
	_px(38 * sx, 32 * sy + bob, 8 * sx, 25 * sy, Color("#6c2a24"))
	_px(18 * sx, 43 * sy + bob, 22 * sx, 4 * sy, accent_color)
	_px(19 * sx, 59 * sy + bob, 8 * sx, 13 * sy, Color("#16151a"))
	_px(31 * sx, 59 * sy + bob, 8 * sx, 13 * sy, Color("#16151a"))
	_px(37 * sx, 19 * sy + bob, 6 * sx, 38 * sy, Color("#8b6f3d"))
	_px(41 * sx, 18 * sy + bob, 10 * sx, 11 * sy, Color("#d9903d"))
	_px(24 * sx, 23 * sy + bob, 8 * sx, 3 * sy, Color("#f2d19b"))

func _px(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(Vector2(x, y), Vector2(w, h)), color)

extends Control

var texture_path := "res://assets/characters/merchant-idle-cropped.png"
var texture: Texture2D
var draw_fallback_if_loaded := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_texture()
	queue_redraw()

func _load_texture() -> void:
	var image := Image.new()
	var error := image.load(texture_path)
	if error == OK:
		texture = ImageTexture.create_from_image(image)

func _draw() -> void:
	if texture != null and not draw_fallback_if_loaded:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
		return
	_draw_fallback_merchant()

func _draw_fallback_merchant() -> void:
	var sx := size.x / 52.0
	var sy := size.y / 76.0
	var center := size.x * 0.5
	_draw_px(Vector2(center - 19 * sx, 68 * sy), Vector2(38 * sx, 6 * sy), Color(0, 0, 0, 0.25))
	_draw_px(Vector2(center - 10 * sx, 10 * sy), Vector2(20 * sx, 17 * sy), Color("#d0a06f"))
	_draw_px(Vector2(center - 12 * sx, 6 * sy), Vector2(24 * sx, 8 * sy), Color("#5f4030"))
	_draw_px(Vector2(center - 16 * sx, 29 * sy), Vector2(32 * sx, 30 * sy), Color("#c07a2c"))
	_draw_px(Vector2(center - 20 * sx, 34 * sy), Vector2(8 * sx, 24 * sy), Color("#7a4c23"))
	_draw_px(Vector2(center + 12 * sx, 34 * sy), Vector2(8 * sx, 24 * sy), Color("#7a4c23"))
	_draw_px(Vector2(center - 12 * sx, 59 * sy), Vector2(8 * sx, 14 * sy), Color("#1b1818"))
	_draw_px(Vector2(center + 4 * sx, 59 * sy), Vector2(8 * sx, 14 * sy), Color("#1b1818"))
	_draw_px(Vector2(center - 17 * sx, 42 * sy), Vector2(34 * sx, 5 * sy), Color("#f1b24d"))
	_draw_px(Vector2(center + 14 * sx, 45 * sy), Vector2(12 * sx, 12 * sy), Color("#8a5b2d"))
	_draw_px(Vector2(center - 24 * sx, 46 * sy), Vector2(12 * sx, 12 * sy), Color("#b57b35"))

func _draw_px(pos: Vector2, rect_size: Vector2, color: Color) -> void:
	draw_rect(Rect2(pos, rect_size), color)

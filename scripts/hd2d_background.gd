extends Control

const BG_PATH := "res://assets/maps/west-market-hd2d-bg.png"
const WORLD_SIZE := Vector2(2400, 720)

var texture: Texture2D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	size = WORLD_SIZE
	custom_minimum_size = WORLD_SIZE
	_load_background()
	queue_redraw()

func _load_background() -> void:
	var image := Image.new()
	var error := image.load(BG_PATH)
	if error == OK:
		texture = ImageTexture.create_from_image(image)

func _draw() -> void:
	var draw_size := size
	if draw_size.x < 1.0 or draw_size.y < 1.0:
		draw_size = WORLD_SIZE
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, draw_size), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, draw_size), Color("#12151b"))
	draw_rect(Rect2(Vector2.ZERO, draw_size), Color(0.04, 0.04, 0.06, 0.08))
	draw_rect(Rect2(Vector2(0, 0), Vector2(draw_size.x, 118)), Color(0, 0, 0, 0.18))
	draw_rect(Rect2(Vector2(0, 560), Vector2(draw_size.x, 160)), Color(0, 0, 0, 0.12))

extends Control

const TEXTURE_PATH := "res://assets/characters/buliangren-battle-pixel.png"

var texture: Texture2D
var time := 0.0
var face_left := true

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var image := Image.new()
	if image.load(TEXTURE_PATH) == OK:
		texture = ImageTexture.create_from_image(image)
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var breathe: float = sin(time * 2.0) * 2.0
	draw_rect(Rect2(Vector2(size.x * 0.22, size.y * 0.91), Vector2(size.x * 0.56, size.y * 0.055)), Color(0, 0, 0, 0.32))
	if texture == null:
		return
	if face_left:
		draw_set_transform(Vector2(size.x, breathe), 0.0, Vector2(-1, 1))
		draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_texture_rect(texture, Rect2(Vector2(0, breathe), size), false)

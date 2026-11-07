extends Control

const TEXTURE_PATH := "res://assets/characters/battle-bandits.png"

var texture: Texture2D
var source_rect := Rect2(0, 0, 512, 512)
var breathe_phase := 0.0
var time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var image := Image.new()
	if image.load(TEXTURE_PATH) == OK:
		texture = ImageTexture.create_from_image(image)
	queue_redraw()

func setup(rect: Rect2, phase: float = 0.0) -> void:
	source_rect = rect
	breathe_phase = phase
	queue_redraw()

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var breathe := sin(time * 2.1 + breathe_phase) * 2.0
	var dest := Rect2(Vector2(0, breathe), size)
	draw_rect(Rect2(Vector2(size.x * 0.18, size.y * 0.91), Vector2(size.x * 0.64, size.y * 0.05)), Color(0, 0, 0, 0.28))
	if texture != null:
		draw_texture_rect_region(texture, dest, source_rect)

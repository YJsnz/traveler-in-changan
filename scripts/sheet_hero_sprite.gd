extends Control

const SHEET_PATH := "res://assets/characters/buliangren-map-sheet-grid.png"
const COLS := 4
const ROWS := 4

var texture: Texture2D
var cell_size := Vector2.ZERO
var row := 0
var col := 0
var walking := false
var walk_time := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_sheet()
	queue_redraw()

func _process(delta: float) -> void:
	if walking:
		walk_time += delta
		col = 1 + int(walk_time * 10.0) % 3
	else:
		col = 0
	queue_redraw()

func set_motion(direction: Vector2) -> void:
	walking = direction.length() > 0.05
	if walking:
		if abs(direction.x) > abs(direction.y):
			row = 2 if direction.x >= 0.0 else 1
		elif direction.y < 0.0:
			row = 3
		else:
			row = 0
	queue_redraw()

func _load_sheet() -> void:
	var image := Image.new()
	var error := image.load(SHEET_PATH)
	if error == OK:
		texture = ImageTexture.create_from_image(image)
		cell_size = Vector2(float(image.get_width()) / COLS, float(image.get_height()) / ROWS)

func _draw() -> void:
	_draw_shadow_and_ripple()
	if texture == null or cell_size == Vector2.ZERO:
		_draw_fallback()
		return
	var src := Rect2(Vector2(col * cell_size.x, row * cell_size.y), cell_size)
	draw_texture_rect_region(texture, Rect2(Vector2.ZERO, size), src)

func _draw_shadow_and_ripple() -> void:
	draw_rect(Rect2(Vector2(size.x * 0.18, size.y * 0.90), Vector2(size.x * 0.64, size.y * 0.07)), Color(0, 0, 0, 0.30))
	if walking:
		var phase := int(walk_time * 10.0) % 3
		if phase == 0:
			draw_rect(Rect2(Vector2(size.x * 0.30, size.y * 0.94), Vector2(size.x * 0.34, 2)), Color(0.72, 0.84, 0.86, 0.18))

func _draw_fallback() -> void:
	draw_rect(Rect2(Vector2(size.x * 0.35, size.y * 0.18), Vector2(size.x * 0.30, size.y * 0.22)), Color("#d3a477"))
	draw_rect(Rect2(Vector2(size.x * 0.24, size.y * 0.40), Vector2(size.x * 0.52, size.y * 0.42)), Color("#25201e"))
	draw_rect(Rect2(Vector2(size.x * 0.18, size.y * 0.35), Vector2(size.x * 0.64, size.y * 0.12)), Color("#10151b"))
	draw_rect(Rect2(Vector2(size.x * 0.33, size.y * 0.80), Vector2(size.x * 0.12, size.y * 0.16)), Color("#111318"))
	draw_rect(Rect2(Vector2(size.x * 0.55, size.y * 0.80), Vector2(size.x * 0.12, size.y * 0.16)), Color("#111318"))

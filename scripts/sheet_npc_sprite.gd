extends Control

const SHEET_PATH := "res://assets/characters/chapter-01-npc-sheet-image2.png"
const GROUPS := 4
const COLS_PER_GROUP := 3
const ROWS := 4

var texture: Texture2D
var cell_size := Vector2.ZERO
var npc_index := 0
var row := 0
var col := 0
var highlighted := false
var t := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_sheet()
	queue_redraw()

func _process(delta: float) -> void:
	t += delta
	col = int(t * 2.6) % COLS_PER_GROUP
	queue_redraw()

func setup(index: int) -> void:
	npc_index = clamp(index, 0, GROUPS - 1)
	queue_redraw()

func set_highlight(active: bool) -> void:
	highlighted = active
	queue_redraw()

func _load_sheet() -> void:
	var image := Image.new()
	var error := image.load(SHEET_PATH)
	if error == OK:
		texture = ImageTexture.create_from_image(image)
		cell_size = Vector2(float(image.get_width()) / float(GROUPS * COLS_PER_GROUP), float(image.get_height()) / float(ROWS))

func _draw() -> void:
	_draw_ground()
	if texture == null or cell_size == Vector2.ZERO:
		_draw_fallback()
		return
	var source_col := npc_index * COLS_PER_GROUP + col
	var src := Rect2(Vector2(source_col * cell_size.x, row * cell_size.y), cell_size)
	var breathe := sin(t * 2.0 + float(npc_index)) * 1.0
	var draw_rect := Rect2(Vector2(0, breathe), size)
	draw_texture_rect_region(texture, draw_rect, src)

func _draw_ground() -> void:
	if highlighted:
		draw_rect(Rect2(Vector2(size.x * 0.16, size.y * 0.88), Vector2(size.x * 0.68, size.y * 0.08)), Color(0.95, 0.62, 0.18, 0.25))
	draw_rect(Rect2(Vector2(size.x * 0.20, size.y * 0.91), Vector2(size.x * 0.60, size.y * 0.06)), Color(0, 0, 0, 0.25))

func _draw_fallback() -> void:
	draw_rect(Rect2(Vector2(size.x * 0.35, size.y * 0.18), Vector2(size.x * 0.30, size.y * 0.22)), Color("#d0a070"))
	draw_rect(Rect2(Vector2(size.x * 0.25, size.y * 0.40), Vector2(size.x * 0.50, size.y * 0.42)), Color("#d9903d"))
	draw_rect(Rect2(Vector2(size.x * 0.32, size.y * 0.80), Vector2(size.x * 0.12, size.y * 0.16)), Color("#151519"))
	draw_rect(Rect2(Vector2(size.x * 0.55, size.y * 0.80), Vector2(size.x * 0.12, size.y * 0.16)), Color("#151519"))

extends Control

var texture_path := "res://assets/characters/buliangren-idle-cropped.png"
var texture: Texture2D
var draw_fallback_if_loaded := false
var use_pixel_walk := false
var facing := 1
var facing_mode := "down"
var walking := false
var walk_time := 0.0
var last_splash_frame := -1

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_load_texture()
	queue_redraw()

func _process(delta: float) -> void:
	if walking:
		walk_time += delta
		queue_redraw()

func set_motion(direction: Vector2) -> void:
	walking = direction.length() > 0.05
	if walking:
		if abs(direction.x) > abs(direction.y):
			facing_mode = "side"
			facing = 1 if direction.x >= 0.0 else -1
		elif direction.y < 0.0:
			facing_mode = "up"
		else:
			facing_mode = "down"
	queue_redraw()

func _load_texture() -> void:
	var image := Image.new()
	var error := image.load(texture_path)
	if error == OK:
		texture = ImageTexture.create_from_image(image)

func _draw() -> void:
	if texture != null and not draw_fallback_if_loaded and not use_pixel_walk:
		if facing < 0:
			draw_set_transform(Vector2(size.x, 0), 0.0, Vector2(-1, 1))
			draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_texture_rect(texture, Rect2(Vector2.ZERO, size), false)
		return

	var frame := 0
	if walking:
		frame = int(walk_time * 12.0) % 8
	_draw_map_hero(frame)

func _draw_map_hero(frame: int) -> void:
	var sx := size.x / 44.0
	var sy := size.y / 78.0
	var step := 0.0
	var bob := 0.0
	var arm := 0.0
	var cloak := 0.0
	if walking:
		var phase := frame % 4
		if phase == 0:
			step = -3.0 * sx
			arm = 2.0 * sx
			cloak = -1.5 * sx
		elif phase == 1:
			bob = -1.0 * sy
		elif phase == 2:
			step = 3.0 * sx
			arm = -2.0 * sx
			cloak = 1.5 * sx
		else:
			bob = -1.0 * sy

	if facing_mode == "side" and facing < 0:
		draw_set_transform(Vector2(size.x, 0), 0.0, Vector2(-1, 1))

	_draw_shadow(sx, sy)
	_draw_step_ripple(sx, sy, frame)
	if facing_mode == "up":
		_draw_back_body(sx, sy, bob, step, arm, cloak)
	elif facing_mode == "side":
		_draw_side_body(sx, sy, bob, step, arm, cloak)
	else:
		_draw_front_body(sx, sy, bob, step, arm, cloak)

	if facing_mode == "side" and facing < 0:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_shadow(sx: float, sy: float) -> void:
	_px(8 * sx, 70 * sy, 29 * sx, 5 * sy, Color(0, 0, 0, 0.34))
	_px(13 * sx, 72 * sy, 19 * sx, 3 * sy, Color(0, 0, 0, 0.18))

func _draw_step_ripple(sx: float, sy: float, frame: int) -> void:
	if not walking:
		return
	var phase := frame % 4
	if phase == 0 or phase == 2:
		var offset := -6.0 * sx if phase == 0 else 6.0 * sx
		draw_rect(Rect2(Vector2(18 * sx + offset, 71 * sy), Vector2(10 * sx, 2 * sy)), Color(0.70, 0.82, 0.84, 0.25))
		draw_rect(Rect2(Vector2(15 * sx + offset, 74 * sy), Vector2(16 * sx, 1 * sy)), Color(0.70, 0.82, 0.84, 0.16))

func _draw_front_body(sx: float, sy: float, bob: float, step: float, arm: float, cloak: float) -> void:
	var o := Vector2(0, bob)
	_px(17 * sx, 5 * sy + bob, 11 * sx, 6 * sy, Color("#17120f"))
	_px(15 * sx, 10 * sy + bob, 15 * sx, 12 * sy, Color("#d3a477"))
	_px(13 * sx, 8 * sy + bob, 19 * sx, 6 * sy, Color("#211816"))
	_px(12 * sx, 23 * sy + bob, 21 * sx, 8 * sy, Color("#10151b"))
	_px(10 * sx + cloak, 29 * sy + bob, 8 * sx, 30 * sy, Color("#10151b"))
	_px(15 * sx, 28 * sy + bob, 17 * sx, 31 * sy, Color("#2a2420"))
	_px(16 * sx, 31 * sy + bob, 15 * sx, 5 * sy, Color("#3a2c22"))
	_px(12 * sx + arm, 32 * sy + bob, 5 * sx, 24 * sy, Color("#181b20"))
	_px(31 * sx - arm, 32 * sy + bob, 5 * sx, 24 * sy, Color("#181b20"))
	_px(14 * sx + step, 58 * sy + bob, 7 * sx, 14 * sy, Color("#121317"))
	_px(24 * sx - step, 58 * sy + bob, 7 * sx, 14 * sy, Color("#121317"))
	_px(12 * sx + step, 70 * sy, 9 * sx, 3 * sy, Color("#2c211d"))
	_px(24 * sx - step, 70 * sy, 9 * sx, 3 * sy, Color("#2c211d"))
	_px(19 * sx, 37 * sy + bob, 4 * sx, 19 * sy, Color("#9b743d"))
	_px(14 * sx, 45 * sy + bob, 18 * sx, 3 * sy, Color("#d49136"))
	_px(29 * sx, 42 * sy + bob, 3 * sx, 19 * sy, Color("#6a4932"))
	_px(32 * sx, 55 * sy + bob, 4 * sx, 9 * sy, Color("#2c211d"))
	_px(17 * sx, 14 * sy + bob, 3 * sx, 2 * sy, Color("#24130f"))
	_px(25 * sx, 14 * sy + bob, 3 * sx, 2 * sy, Color("#24130f"))

func _draw_side_body(sx: float, sy: float, bob: float, step: float, arm: float, cloak: float) -> void:
	_px(18 * sx, 5 * sy + bob, 11 * sx, 6 * sy, Color("#17120f"))
	_px(16 * sx, 10 * sy + bob, 14 * sx, 12 * sy, Color("#d3a477"))
	_px(14 * sx, 8 * sy + bob, 18 * sx, 6 * sy, Color("#211816"))
	_px(12 * sx + cloak, 26 * sy + bob, 16 * sx, 34 * sy, Color("#10151b"))
	_px(17 * sx, 27 * sy + bob, 16 * sx, 32 * sy, Color("#2a2420"))
	_px(18 * sx, 31 * sy + bob, 14 * sx, 4 * sy, Color("#3a2c22"))
	_px(26 * sx + arm, 34 * sy + bob, 5 * sx, 23 * sy, Color("#17191f"))
	_px(17 * sx - arm, 35 * sy + bob, 5 * sx, 20 * sy, Color("#17191f"))
	_px(18 * sx + step, 58 * sy + bob, 7 * sx, 14 * sy, Color("#121317"))
	_px(25 * sx - step, 58 * sy + bob, 7 * sx, 14 * sy, Color("#121317"))
	_px(16 * sx + step, 70 * sy, 10 * sx, 3 * sy, Color("#2c211d"))
	_px(25 * sx - step, 70 * sy, 10 * sx, 3 * sy, Color("#2c211d"))
	_px(24 * sx, 39 * sy + bob, 3 * sx, 20 * sy, Color("#9b743d"))
	_px(17 * sx, 45 * sy + bob, 16 * sx, 3 * sy, Color("#d49136"))
	_px(31 * sx, 42 * sy + bob, 3 * sx, 18 * sy, Color("#6a4932"))
	_px(29 * sx, 15 * sy + bob, 2 * sx, 2 * sy, Color("#24130f"))

func _draw_back_body(sx: float, sy: float, bob: float, step: float, arm: float, cloak: float) -> void:
	_px(16 * sx, 5 * sy + bob, 12 * sx, 6 * sy, Color("#17120f"))
	_px(15 * sx, 10 * sy + bob, 15 * sx, 12 * sy, Color("#241916"))
	_px(13 * sx, 8 * sy + bob, 19 * sx, 7 * sy, Color("#211816"))
	_px(12 * sx + cloak, 24 * sy + bob, 21 * sx, 38 * sy, Color("#10151b"))
	_px(15 * sx, 29 * sy + bob, 18 * sx, 30 * sy, Color("#24221f"))
	_px(13 * sx + arm, 32 * sy + bob, 5 * sx, 23 * sy, Color("#151820"))
	_px(31 * sx - arm, 32 * sy + bob, 5 * sx, 23 * sy, Color("#151820"))
	_px(14 * sx + step, 58 * sy + bob, 7 * sx, 14 * sy, Color("#111318"))
	_px(24 * sx - step, 58 * sy + bob, 7 * sx, 14 * sy, Color("#111318"))
	_px(12 * sx + step, 70 * sy, 9 * sx, 3 * sy, Color("#2c211d"))
	_px(24 * sx - step, 70 * sy, 9 * sx, 3 * sy, Color("#2c211d"))
	_px(17 * sx, 37 * sy + bob, 15 * sx, 3 * sy, Color("#8b6f3d"))
	_px(20 * sx, 43 * sy + bob, 4 * sx, 18 * sy, Color("#9b743d"))

func _px(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(Vector2(x, y), Vector2(w, h)), color)

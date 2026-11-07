extends Control

const PLAYER_SPEED := 260.0
const PLAYER_ACCEL := 12.0
const INTERACT_RANGE := 82.0
const VIEW_SIZE := Vector2(1280, 720)
const WORLD_SIZE := Vector2(8060, 720)
const USE_AI_SCENE := true
const TELEPORT_FADE_ALPHA := 0.72
const TELEPORT_FADE_IN_SECONDS := 0.16
const TELEPORT_FADE_OUT_SECONDS := 0.20
const TELEPORT_EXIT_PUSH := 96.0
const MAP_RECTS := {
	"west_market": Rect2(Vector2(0, 0), Vector2(2400, 720)),
	"spice_alley": Rect2(Vector2(2500, 0), Vector2(1280, 720)),
	"tea_yard": Rect2(Vector2(3860, 0), Vector2(1280, 720)),
	"music_side": Rect2(Vector2(5220, 0), Vector2(1280, 720)),
	"warehouse_cellar": Rect2(Vector2(6580, 0), Vector2(1280, 720)),
}
const Hd2dBackground := preload("res://scripts/hd2d_background.gd")
const SheetHeroSprite := preload("res://scripts/sheet_hero_sprite.gd")
const Hd2dSceneFx := preload("res://scripts/hd2d_scene_fx.gd")
const MapNpcSprite := preload("res://scripts/map_npc_sprite.gd")
const SheetNpcSprite := preload("res://scripts/sheet_npc_sprite.gd")
const InteractionPrompt := preload("res://scripts/interaction_prompt.gd")
const DialogueBalloon := preload("res://scripts/dialogue_balloon.gd")
const HudOverlay := preload("res://scripts/hud_overlay.gd")
const ForegroundOccluder := preload("res://scripts/foreground_occluder.gd")
const HERO_PORTRAIT_PATH := "res://assets/characters/buliangren-idle-cropped.png"
const PLAYER_SPRITE_SIZE := Vector2(54, 72)
const PLAYER_SPRITE_OFFSET := Vector2(-13, -35)
const NPC_SPRITE_SIZE := Vector2(54, 72)
const NPC_MARKER_SIZE := Vector2(54, 76)
const NPC_MARKER_OFFSET := Vector2(24, 54)

var player_pos := Vector2(245, 535)
var player_direction := Vector2.ZERO
var player_velocity := Vector2.ZERO
var camera_x := 0.0
var clues_found := 0
var current_target := -1
var current_map := "west_market"

var world_root: Control
var player: Control
var player_shadow: ColorRect
var hint_label: Label
var clue_label: Label
var dialogue_label: RichTextLabel
var interaction_prompt: Control
var fade_overlay: ColorRect
var dialogue_balloon: Control
var hud_overlay: Control
var intro_overlay: Control
var intro_portrait: TextureRect
var intro_title: Label
var intro_body: RichTextLabel
var intro_hint: Label
var interact_was_down := false
var is_transitioning := false
var intro_active := false
var intro_step := 0
var intro_lines := [
	"长安西市闭鼓之后，本该只剩巡铺的铜铃声。今夜，一封没有署名的急牒送到不良井：灯市尽头，有人死在胡商货栈前。",
	"死者袖中藏着半页账簿，墨迹被雨水洇开，只剩两个字还清楚：玄牒。那是三年前一桩旧案里消失的名目。",
	"沈晏奉命独自入市。明面上，他只是查一桩夜市命案；暗处，他要找出是谁把旧账重新摆到长安灯下。",
]
var text_data := {}
var target_nodes := []
var target_defs := [
	{"id": "gate_spice", "name": "香料巷", "pos": Vector2(330, 535), "kind": "portal", "to": Vector2(2630, 545), "message": "你穿过香料摊旁的窄口，雨水把苏合香的味道压得更沉。"},
	{"id": "gate_tea", "name": "茶肆后院", "pos": Vector2(790, 535), "kind": "portal", "to": Vector2(3990, 548), "message": "你绕过茶肆侧门，后院里只剩雨滴敲着竹帘。"},
	{"id": "gate_music", "name": "乐坊侧门", "pos": Vector2(1250, 535), "kind": "portal", "to": Vector2(5350, 548), "message": "乐坊侧门半掩，暖光从门缝里斜斜漏出来。"},
	{"id": "scene_body", "name": "现场", "pos": Vector2(1710, 532), "kind": "clue", "message": "尸体旁的木牌像军中粮车牌。死者不是普通货商。"},
	{"id": "gate_warehouse", "name": "仓库", "pos": Vector2(2185, 518), "kind": "warehouse_portal", "to": Vector2(6735, 548), "message": "仓库门后有潮湿的土腥味，像一段被埋了十年的路。"},
	{"id": "spice_vendor", "name": "罗三娘", "pos": Vector2(2920, 545), "kind": "clue", "message": "罗三娘压低声音：那箱货没走市门，押箱的人手上有军茧。"},
	{"id": "spice_oil", "name": "破油罐", "pos": Vector2(3260, 552), "kind": "clue", "message": "破油罐里混着香料粉，灯灭前有人在这里停过。"},
	{"id": "exit_spice", "name": "返回西市", "pos": Vector2(2538, 548), "kind": "portal", "to": Vector2(330, 535), "message": "你回到西市主街，雨声重新被人声吞没。"},
	{"id": "tea_porter", "name": "阿犁", "pos": Vector2(4280, 548), "kind": "clue", "message": "阿犁说：箱子不是金银。金银会响，那箱东西一路静得瘆人。"},
	{"id": "tea_crate", "name": "封箱", "pos": Vector2(4620, 548), "kind": "clue", "message": "封箱木钉很新，箱底却有旧军仓的烙印。"},
	{"id": "exit_tea", "name": "返回西市", "pos": Vector2(3898, 548), "kind": "portal", "to": Vector2(790, 535), "message": "你从茶肆后院绕回主街。"},
	{"id": "music_performer", "name": "纪闻笛", "pos": Vector2(5640, 548), "kind": "clue", "message": "纪闻笛说：他听到边曲里的“断粮”二字，手抖得把酒洒了。"},
	{"id": "music_cases", "name": "乐器箱", "pos": Vector2(5980, 552), "kind": "clue", "message": "乐器箱下压着半张旧谱，曲调像军中传令。"},
	{"id": "exit_music", "name": "返回西市", "pos": Vector2(5258, 548), "kind": "portal", "to": Vector2(1250, 535), "message": "你离开乐坊侧门，身后的弦声忽然停了。"},
	{"id": "cellar_ledger", "name": "账箱", "pos": Vector2(7040, 552), "kind": "clue", "message": "账箱夹层里藏着玄牒残页，墨迹被潮气浸得发暗。"},
	{"id": "cellar_boss", "name": "韩折冲", "pos": Vector2(7370, 548), "kind": "battle", "message": "韩折冲抬起刀：长安人查案，总爱问谁杀了谁。"},
	{"id": "exit_cellar", "name": "返回西市", "pos": Vector2(6658, 548), "kind": "portal", "to": Vector2(2185, 518), "message": "你退回仓库门口，潮气仍贴在衣摆上。"},
]
var target_done := {}

func _ready() -> void:
	_load_text()
	_make_world_root()
	_make_background()
	_make_market()
	_make_player()
	_make_world_fx()
	_make_foreground()
	_pack_world_children()
	_make_ui()
	_make_screen_fx()
	_update_camera()
	_update_labels()
	_start_intro_scene()

func _make_world_root() -> void:
	world_root = Control.new()
	world_root.name = "WorldRoot"
	world_root.size = WORLD_SIZE
	world_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(world_root)

func _pack_world_children() -> void:
	var children := get_children()
	for child in children:
		if child == world_root:
			continue
		remove_child(child)
		world_root.add_child(child)

func _load_text() -> void:
	var file := FileAccess.open("res://data/zh_cn.json", FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("town"):
		text_data = parsed["town"]

func _process(delta: float) -> void:
	if not is_transitioning and not intro_active:
		_move_player(delta)
	_update_camera()
	_find_target()
	if not is_transitioning and not intro_active:
		_poll_interact()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_E or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
				if intro_active:
					_advance_intro()
					return
				_interact()

func _poll_interact() -> void:
	var is_down := Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_ENTER) or Input.is_action_pressed("ui_accept")
	if is_down and not interact_was_down:
		_interact()
	interact_was_down = is_down

func _make_background() -> void:
	if USE_AI_SCENE:
		_add_map_texture("res://assets/maps/west-market-hd2d-bg.png", Vector2(0, 0), Vector2(2400, 720))
		_add_map_texture("res://assets/maps/spice-alley-hd2d-bg.png", Vector2(2500, 0), Vector2(1280, 720))
		_add_map_texture("res://assets/maps/tea-yard-hd2d-bg.png", Vector2(3860, 0), Vector2(1280, 720))
		_add_map_texture("res://assets/maps/music-house-side-hd2d-bg.png", Vector2(5220, 0), Vector2(1280, 720))
		_add_map_texture("res://assets/maps/warehouse-cellar-hd2d-bg.png", Vector2(6580, 0), Vector2(1280, 720))
		return

	var bg := ColorRect.new()
	bg.color = Color("#12151b")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	_add_rect(Vector2(0, 96), Vector2(1280, 28), Color("#0f1117"))
	_add_rect(Vector2(0, 118), Vector2(1280, 56), Color("#191820"))
	_add_rect(Vector2(0, 174), Vector2(1280, 32), Color("#242129"))
	_add_rect(Vector2(0, 206), Vector2(1280, 16), Color("#15151c"))
	_add_rect(Vector2(84, 144), Vector2(170, 20), Color("#2c2528"))
	_add_rect(Vector2(378, 136), Vector2(235, 22), Color("#2c2528"))
	_add_rect(Vector2(760, 140), Vector2(250, 22), Color("#2c2528"))
	_add_rect(Vector2(1040, 152), Vector2(170, 20), Color("#2c2528"))
	_add_roof_tiles(Vector2(70, 132), 210, Color("#33282a"))
	_add_roof_tiles(Vector2(360, 124), 280, Color("#30262a"))
	_add_roof_tiles(Vector2(740, 128), 300, Color("#34292a"))
	_add_roof_tiles(Vector2(1018, 140), 210, Color("#2d2525"))
	_add_far_window(Vector2(122, 176))
	_add_far_window(Vector2(430, 170))
	_add_far_window(Vector2(824, 172))
	_add_far_window(Vector2(1086, 184))

func _add_map_texture(path: String, pos: Vector2, draw_size: Vector2) -> void:
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		_add_rect(pos, draw_size, Color("#12151b"))
		return
	var texture := ImageTexture.create_from_image(image)
	var rect := TextureRect.new()
	rect.texture = texture
	rect.position = pos
	rect.size = draw_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(rect)
	_add_rect(pos, Vector2(draw_size.x, 118), Color(0, 0, 0, 0.18))
	_add_rect(pos + Vector2(0, 560), Vector2(draw_size.x, 160), Color(0, 0, 0, 0.10))

func _make_market() -> void:
	if USE_AI_SCENE:
		_make_ai_scene_overlay()
		return

	_add_rect(Vector2(0, 470), Vector2(1280, 34), Color("#17191f"))
	_add_rect(Vector2(0, 520), Vector2(1280, 210), Color("#24272d"))
	_add_rect(Vector2(0, 495), Vector2(1280, 28), Color("#6f7471"))
	_add_rect(Vector2(0, 700), Vector2(1280, 24), Color("#6f7471"))
	_add_stone_paving()
	_add_hd2d_stage_blocks()
	_add_reflection(Vector2(180, 604), Vector2(220, 14), Color(0.85, 0.48, 0.22, 0.22))
	_add_reflection(Vector2(520, 626), Vector2(250, 12), Color(0.37, 0.54, 0.46, 0.20))
	_add_reflection(Vector2(820, 606), Vector2(190, 10), Color(0.86, 0.63, 0.28, 0.18))

	_add_stall(Vector2(150, 250), tr_text("stall_spice"), Color("#9f3028"))
	_add_stall(Vector2(430, 250), tr_text("stall_tea"), Color("#5f8a75"))
	_add_stall(Vector2(720, 250), tr_text("music_house"), Color("#8b6f3d"))
	_add_warehouse(Vector2(1000, 250))

	_add_lantern(Vector2(250, 210))
	_add_lantern(Vector2(620, 215))
	_add_lantern(Vector2(930, 210))
	_add_light_pool(Vector2(286, 354), Vector2(210, 58))
	_add_light_pool(Vector2(656, 358), Vector2(225, 58))
	_add_light_pool(Vector2(966, 356), Vector2(190, 52))
	_add_market_props()

	_add_marker(0, Color("#d9903d"))
	_add_marker(1, Color("#8b6f3d"))
	_add_marker(2, Color("#9f3028"))
	_add_marker(3, Color("#5f8a75"))
	_add_marker(4, Color("#3a3130"))

	_add_rain_lines()
	_add_vignette()

func _make_ai_scene_overlay() -> void:
	for map_x in [0, 2500, 3860, 5220, 6580]:
		_add_rect(Vector2(map_x, 575), Vector2(1280 if map_x > 0 else 2400, 30), Color(0.02, 0.02, 0.025, 0.08))
		_add_rect(Vector2(map_x + 16, 690), Vector2(1248 if map_x > 0 else 2368, 2), Color(0.67, 0.46, 0.18, 0.22))
	_add_rect(Vector2(0, 575), Vector2(WORLD_SIZE.x, 30), Color(0.02, 0.02, 0.025, 0.08))
	_add_reflection(Vector2(180, 598), Vector2(220, 8), Color(0.85, 0.58, 0.30, 0.09))
	_add_reflection(Vector2(520, 618), Vector2(250, 7), Color(0.52, 0.66, 0.64, 0.08))
	_add_reflection(Vector2(820, 598), Vector2(190, 7), Color(0.86, 0.63, 0.28, 0.08))
	_add_reflection(Vector2(1260, 604), Vector2(230, 8), Color(0.85, 0.52, 0.24, 0.08))
	_add_reflection(Vector2(1650, 620), Vector2(260, 7), Color(0.50, 0.62, 0.68, 0.07))
	_add_reflection(Vector2(2020, 600), Vector2(220, 8), Color(0.90, 0.58, 0.28, 0.08))

	_add_extended_street_details()

	for i in range(target_defs.size()):
		_add_marker(i, _target_color(i))

func _add_extended_street_details() -> void:
	for i in range(6):
		var x := 1180.0 + i * 185.0
		_add_rect(Vector2(x, 510 + (i % 2) * 12), Vector2(42, 52), Color(0.12, 0.09, 0.075, 0.30))
		_add_rect(Vector2(x + 6, 520 + (i % 2) * 12), Vector2(30, 10), Color(0.62, 0.42, 0.22, 0.16))
	for i in range(5):
		var x := 1320.0 + i * 210.0
		_add_rect(Vector2(x, 318), Vector2(10, 150), Color(0.18, 0.12, 0.08, 0.42))
		_add_glow_rect(Vector2(x - 52, 388), Vector2(114, 72), Color(0.95, 0.54, 0.18, 0.08))
		_add_rect(Vector2(x - 15, 404), Vector2(40, 30), Color("#d9903d"))
		_add_rect(Vector2(x - 11, 408), Vector2(32, 22), Color(1.0, 0.78, 0.32, 0.14))
	_add_rect(Vector2(1310, 395), Vector2(155, 44), Color(0.16, 0.10, 0.07, 0.42))
	_add_rect(Vector2(1440, 410), Vector2(72, 28), Color(0.44, 0.25, 0.12, 0.30))
	_add_rect(Vector2(1545, 392), Vector2(180, 52), Color(0.12, 0.08, 0.06, 0.36))
	_add_rect(Vector2(1840, 386), Vector2(210, 54), Color(0.14, 0.09, 0.07, 0.38))
	_add_rect(Vector2(2075, 375), Vector2(180, 88), Color(0.12, 0.08, 0.06, 0.40))
	_add_rect(Vector2(2136, 405), Vector2(70, 62), Color(0.02, 0.018, 0.016, 0.55))
	_add_label(tr_text("warehouse"), Vector2(2175, 366), 16, Color("#f2e6cf"))

func _add_scene_pin(text: String, pos: Vector2) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("#f2e6cf"))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(label)

func _make_ui() -> void:
	var title := Label.new()
	title.text = tr_text("title")
	title.position = Vector2(28, 18)
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", Color("#f2e6cf"))
	add_child(title)

	hint_label = Label.new()
	hint_label.position = Vector2(28, 58)
	hint_label.add_theme_font_size_override("font_size", 16)
	hint_label.add_theme_color_override("font_color", Color("#d8c7a2"))
	add_child(hint_label)

	clue_label = Label.new()
	clue_label.position = Vector2(28, 84)
	clue_label.add_theme_font_size_override("font_size", 16)
	clue_label.add_theme_color_override("font_color", Color("#d9903d"))
	add_child(clue_label)

	var panel := PanelContainer.new()
	panel.position = Vector2(42, 606)
	panel.custom_minimum_size = Vector2(760, 72)
	panel.add_theme_stylebox_override("panel", _stylebox(Color(0.07, 0.08, 0.10, 0.74), Color(0.67, 0.46, 0.18, 0.80), 2))
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	dialogue_label = RichTextLabel.new()
	dialogue_label.bbcode_enabled = true
	dialogue_label.fit_content = false
	dialogue_label.custom_minimum_size = Vector2(0, 48)
	dialogue_label.add_theme_color_override("default_color", Color("#f2e6cf"))
	margin.add_child(dialogue_label)

func _make_world_fx() -> void:
	var fx := Hd2dSceneFx.new()
	add_child(fx)

func _make_foreground() -> void:
	var fg := ForegroundOccluder.new()
	add_child(fg)

func _make_screen_fx() -> void:
	dialogue_balloon = DialogueBalloon.new()
	dialogue_balloon.position = Vector2(438, 260)
	dialogue_balloon.visible = false
	add_child(dialogue_balloon)

	hud_overlay = HudOverlay.new()
	add_child(hud_overlay)

	interaction_prompt = InteractionPrompt.new()
	interaction_prompt.visible = false
	add_child(interaction_prompt)

	fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 0)
	fade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(fade_overlay)

func _make_intro_overlay() -> void:
	intro_overlay = Control.new()
	intro_overlay.name = "IntroOverlay"
	intro_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	intro_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(intro_overlay)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.02, 0.025, 0.64)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	intro_overlay.add_child(shade)

	var chapter := Label.new()
	chapter.text = "第一章  西市灯灭"
	chapter.position = Vector2(94, 54)
	chapter.add_theme_font_size_override("font_size", 22)
	chapter.add_theme_color_override("font_color", Color("#d9903d"))
	intro_overlay.add_child(chapter)

	var portrait_frame := PanelContainer.new()
	portrait_frame.position = Vector2(94, 88)
	portrait_frame.custom_minimum_size = Vector2(250, 286)
	portrait_frame.add_theme_stylebox_override("panel", _stylebox(Color(0.035, 0.037, 0.044, 0.86), Color("#8b6f3d"), 2))
	intro_overlay.add_child(portrait_frame)

	var portrait_margin := MarginContainer.new()
	portrait_margin.add_theme_constant_override("margin_left", 8)
	portrait_margin.add_theme_constant_override("margin_right", 8)
	portrait_margin.add_theme_constant_override("margin_top", 8)
	portrait_margin.add_theme_constant_override("margin_bottom", 8)
	portrait_frame.add_child(portrait_margin)

	intro_portrait = TextureRect.new()
	intro_portrait.custom_minimum_size = Vector2(234, 270)
	intro_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	intro_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	intro_portrait.texture = _load_image_texture(HERO_PORTRAIT_PATH)
	portrait_margin.add_child(intro_portrait)

	var portrait_name := Label.new()
	portrait_name.text = "沈晏"
	portrait_name.position = Vector2(122, 334)
	portrait_name.add_theme_font_size_override("font_size", 26)
	portrait_name.add_theme_color_override("font_color", Color("#f2e6cf"))
	intro_overlay.add_child(portrait_name)

	var portrait_role := Label.new()
	portrait_role.text = "万年县不良人"
	portrait_role.position = Vector2(122, 363)
	portrait_role.add_theme_font_size_override("font_size", 15)
	portrait_role.add_theme_color_override("font_color", Color("#c9b486"))
	intro_overlay.add_child(portrait_role)

	var panel := PanelContainer.new()
	panel.position = Vector2(372, 176)
	panel.custom_minimum_size = Vector2(740, 278)
	panel.add_theme_stylebox_override("panel", _stylebox(Color(0.045, 0.045, 0.052, 0.90), Color("#8b6f3d"), 2))
	intro_overlay.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin.add_child(box)

	intro_title = Label.new()
	intro_title.text = "急牒入井"
	intro_title.add_theme_font_size_override("font_size", 26)
	intro_title.add_theme_color_override("font_color", Color("#f2e6cf"))
	box.add_child(intro_title)

	intro_body = RichTextLabel.new()
	intro_body.bbcode_enabled = true
	intro_body.fit_content = false
	intro_body.custom_minimum_size = Vector2(0, 142)
	intro_body.add_theme_font_size_override("normal_font_size", 20)
	intro_body.add_theme_color_override("default_color", Color("#e7d7b6"))
	intro_body.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	box.add_child(intro_body)

	intro_hint = Label.new()
	intro_hint.text = "按 E / Space / Enter 继续"
	intro_hint.add_theme_font_size_override("font_size", 16)
	intro_hint.add_theme_color_override("font_color", Color("#d9903d"))
	box.add_child(intro_hint)

func _load_image_texture(path: String) -> Texture2D:
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		return null
	return ImageTexture.create_from_image(image)

func _start_intro_scene() -> void:
	intro_active = true
	is_transitioning = true
	intro_step = 0
	if player != null:
		player.visible = false
	if player_shadow != null:
		player_shadow.visible = false
	_make_intro_overlay()
	_update_intro_text()
	_show_message("西市灯灭，急牒入井。")

func _advance_intro() -> void:
	if not intro_active:
		return
	intro_step += 1
	if intro_step < intro_lines.size():
		_update_intro_text()
		return
	await _finish_intro_scene()

func _update_intro_text() -> void:
	if intro_body != null:
		intro_body.clear()
		intro_body.append_text(str(intro_lines[intro_step]))
	if intro_hint != null:
		intro_hint.text = "按 E / Space / Enter 继续  %d/%d" % [intro_step + 1, intro_lines.size()]

func _finish_intro_scene() -> void:
	if intro_overlay != null:
		var fade := create_tween()
		fade.tween_property(intro_overlay, "modulate", Color(1, 1, 1, 0), 0.18)
		await fade.finished
		intro_overlay.queue_free()
		intro_overlay = null
	var arrival := player_pos
	player_pos = Vector2(72, arrival.y)
	player_velocity = Vector2.ZERO
	if player != null:
		player.visible = true
	if player_shadow != null:
		player_shadow.visible = true
	_update_player()
	_update_camera()
	var walk := create_tween()
	walk.tween_method(_set_player_intro_position, player_pos, arrival, 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await walk.finished
	player_velocity = Vector2.ZERO
	_update_player()
	_update_camera()
	intro_active = false
	is_transitioning = false
	_show_message(tr_text("intro"))

func _set_player_intro_position(pos: Vector2) -> void:
	player_pos = pos
	player_velocity = Vector2.RIGHT * PLAYER_SPEED * 0.45
	_update_player()
	_update_camera()

func _make_player() -> void:
	player_shadow = _make_shadow(player_pos + Vector2(14, 43), Vector2(42, 10))
	add_child(player_shadow)
	player = SheetHeroSprite.new()
	player.size = PLAYER_SPRITE_SIZE
	player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(player)

	var name_label := Label.new()
	name_label.text = tr_text("constable")
	name_label.position = Vector2(-22, -18)
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", Color("#f2e6cf"))
	player.add_child(name_label)
	_update_player()

func _add_stall(pos: Vector2, label_text: String, color: Color) -> void:
	_add_rect(pos + Vector2(10, 8), Vector2(190, 92), Color(0, 0, 0, 0.18))
	_add_rect(pos, Vector2(190, 92), Color("#25232a"))
	_add_rect(pos + Vector2(0, -20), Vector2(190, 24), color)
	_add_rect(pos + Vector2(0, 0), Vector2(190, 8), Color(1, 1, 1, 0.08))
	_add_rect(pos + Vector2(26, 92), Vector2(142, 9), Color("#1a181e"))
	_add_rect(pos + Vector2(34, 76), Vector2(28, 16), Color("#3d2d24"))
	_add_rect(pos + Vector2(126, 74), Vector2(34, 18), Color("#433121"))
	_add_label(label_text, pos + Vector2(34, 34), 16, Color("#f2e6cf"))

func _add_warehouse(pos: Vector2) -> void:
	_add_rect(pos + Vector2(12, 12), Vector2(180, 132), Color(0, 0, 0, 0.18))
	_add_rect(pos, Vector2(180, 132), Color("#2c2624"))
	_add_rect(pos + Vector2(0, -18), Vector2(180, 22), Color("#3a2f2b"))
	_add_rect(pos + Vector2(55, 58), Vector2(70, 74), Color("#151111"))
	_add_rect(pos + Vector2(54, 56), Vector2(72, 8), Color("#0d0a0a"))
	_add_rect(pos + Vector2(24, 96), Vector2(26, 28), Color("#4a3828"))
	_add_rect(pos + Vector2(132, 86), Vector2(30, 38), Color("#3b3028"))
	_add_label(tr_text("warehouse"), pos + Vector2(42, 28), 16, Color("#f2e6cf"))

func _add_lantern(pos: Vector2) -> void:
	_add_rect(pos, Vector2(10, 70), Color("#5f4030"))
	_add_glow_rect(pos + Vector2(-62, 24), Vector2(134, 78), Color(0.85, 0.48, 0.16, 0.10))
	_add_glow_rect(pos + Vector2(-36, 34), Vector2(82, 54), Color(0.92, 0.55, 0.18, 0.16))
	_add_rect(pos + Vector2(-14, 40), Vector2(38, 30), Color("#d9903d"))

func _add_marker(index: int, color: Color) -> void:
	var target: Dictionary = target_defs[index]
	var marker := Control.new()
	marker.position = target["pos"] - NPC_MARKER_OFFSET
	marker.size = NPC_MARKER_SIZE
	add_child(marker)
	target_nodes.append(marker)

	var kind := str(target["kind"])
	if kind == "clue" and (str(target["id"]).contains("scene") or str(target["id"]).contains("oil") or str(target["id"]).contains("crate") or str(target["id"]).contains("ledger") or str(target["id"]).contains("cases")):
		_add_clue_object(marker, color)
	elif kind == "portal" or kind == "warehouse_portal":
		_add_crate_marker(marker)
	else:
		_add_npc_sprite(marker, color, index)

	var label := Label.new()
	label.text = target_name(index)
	label.position = Vector2(-10, -18)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color("#f2e6cf"))
	marker.add_child(label)

func _target_color(index: int) -> Color:
	var kind := str(target_defs[index]["kind"])
	if kind == "portal":
		return Color("#6f7471")
	if kind == "warehouse_portal":
		return Color("#3a3130")
	if kind == "battle":
		return Color("#9f3028")
	if str(target_defs[index]["id"]).contains("music"):
		return Color("#9f3028")
	if str(target_defs[index]["id"]).contains("tea"):
		return Color("#8b6f3d")
	if str(target_defs[index]["id"]).contains("spice"):
		return Color("#d9903d")
	return Color("#5f8a75")

func _add_npc_sprite(parent: Control, color: Color, index: int) -> void:
	var npc := SheetNpcSprite.new()
	npc.position = Vector2.ZERO
	npc.size = NPC_SPRITE_SIZE
	npc.setup(_npc_variant_for_target(str(target_defs[index]["id"])))
	parent.add_child(npc)

func _npc_variant_for_target(target_id: String) -> int:
	if target_id == "spice_vendor":
		return 0
	if target_id == "tea_porter":
		return 1
	if target_id == "music_performer":
		return 2
	if target_id == "cellar_boss":
		return 3
	return 0

func _add_clue_object(parent: Control, color: Color) -> void:
	_add_child_rect(parent, Vector2(4, 68), Vector2(44, 9), Color(0, 0, 0, 0.25))
	_add_child_rect(parent, Vector2(20, 32), Vector2(20, 32), color)
	_add_child_rect(parent, Vector2(28, 22), Vector2(8, 16), Color("#29423a"))
	_add_child_rect(parent, Vector2(15, 56), Vector2(14, 8), Color("#4a342b"))
	_add_child_rect(parent, Vector2(34, 58), Vector2(12, 6), Color("#5e3d2c"))
	_add_child_rect(parent, Vector2(10, 44), Vector2(36, 6), Color(0.85, 0.48, 0.16, 0.16))

func _add_crate_marker(parent: Control) -> void:
	_add_child_rect(parent, Vector2(4, 68), Vector2(44, 9), Color(0, 0, 0, 0.25))
	_add_child_rect(parent, Vector2(12, 38), Vector2(34, 28), Color("#3a3130"))
	_add_child_rect(parent, Vector2(15, 41), Vector2(28, 5), Color("#5a4634"))
	_add_child_rect(parent, Vector2(28, 38), Vector2(5, 28), Color("#201b1a"))

func _add_child_rect(parent: Control, pos: Vector2, size: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.color = color
	rect.position = pos
	rect.size = size
	parent.add_child(rect)

func _add_roof_tiles(pos: Vector2, width: int, color: Color) -> void:
	for x in range(0, width, 28):
		_add_rect(pos + Vector2(x, 0), Vector2(24, 7), color)
		_add_rect(pos + Vector2(x + 8, 7), Vector2(24, 7), Color(color.r * 0.78, color.g * 0.78, color.b * 0.78, 1.0))

func _add_far_window(pos: Vector2) -> void:
	_add_rect(pos, Vector2(34, 18), Color(0.85, 0.48, 0.16, 0.14))
	_add_rect(pos + Vector2(15, 0), Vector2(3, 18), Color("#141218"))
	_add_rect(pos + Vector2(0, 8), Vector2(34, 3), Color("#141218"))

func _add_stone_paving() -> void:
	for y in range(524, 700, 32):
		_add_rect(Vector2(0, y), Vector2(1280, 2), Color(1, 1, 1, 0.05))
	for x in range(40, 1240, 92):
		_add_rect(Vector2(x, 524), Vector2(2, 176), Color(1, 1, 1, 0.035))
	for x in range(0, 1280, 128):
		_add_rect(Vector2(x + 12, 556), Vector2(70, 3), Color(0, 0, 0, 0.10))
		_add_rect(Vector2(x + 64, 644), Vector2(82, 3), Color(0, 0, 0, 0.10))

func _add_hd2d_stage_blocks() -> void:
	_add_rect(Vector2(70, 612), Vector2(480, 30), Color("#3a3730"))
	_add_rect(Vector2(90, 642), Vector2(420, 24), Color("#2d2a25"))
	_add_rect(Vector2(720, 606), Vector2(500, 32), Color("#3a3730"))
	_add_rect(Vector2(748, 638), Vector2(410, 26), Color("#2d2a25"))
	for i in range(8):
		_add_rect(Vector2(100 + i * 54, 610), Vector2(44, 11), Color("#5c5548"))
		_add_rect(Vector2(762 + i * 50, 604), Vector2(40, 11), Color("#5c5548"))
	_add_rect(Vector2(112, 420), Vector2(72, 16), Color("#504234"))
	_add_rect(Vector2(96, 436), Vector2(104, 22), Color("#3b3028"))
	_add_rect(Vector2(1030, 430), Vector2(80, 18), Color("#504234"))
	_add_rect(Vector2(1014, 448), Vector2(112, 24), Color("#3b3028"))

func _add_market_props() -> void:
	_add_rect(Vector2(110, 404), Vector2(44, 48), Color("#3d2d24"))
	_add_rect(Vector2(120, 414), Vector2(24, 38), Color("#56402c"))
	_add_rect(Vector2(392, 410), Vector2(38, 42), Color("#2b2524"))
	_add_rect(Vector2(674, 404), Vector2(40, 48), Color("#3f3028"))
	_add_rect(Vector2(882, 408), Vector2(46, 44), Color("#332a26"))
	_add_rect(Vector2(1118, 410), Vector2(42, 42), Color("#2b2524"))

func _add_rain_lines() -> void:
	for i in range(18):
		var x := 40 + i * 68
		var y := 120 + (i % 5) * 48
		_add_rect(Vector2(x, y), Vector2(2, 24), Color(0.62, 0.74, 0.82, 0.12))

func _add_rect(pos: Vector2, size: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.color = color
	rect.position = pos
	rect.size = size
	add_child(rect)

func _add_glow_rect(pos: Vector2, size: Vector2, color: Color) -> void:
	var rect := ColorRect.new()
	rect.color = color
	rect.position = pos
	rect.size = size
	add_child(rect)

func _add_light_pool(center: Vector2, size: Vector2) -> void:
	var pool := ColorRect.new()
	pool.color = Color(0.86, 0.52, 0.20, 0.13)
	pool.position = center - size * 0.5
	pool.size = size
	add_child(pool)

func _add_reflection(pos: Vector2, size: Vector2, color: Color) -> void:
	var reflection := ColorRect.new()
	reflection.color = color
	reflection.position = pos
	reflection.size = size
	add_child(reflection)

func _add_shadow(center: Vector2, size: Vector2) -> void:
	var shadow := _make_shadow(center, size)
	add_child(shadow)

func _make_shadow(center: Vector2, size: Vector2) -> ColorRect:
	var shadow := ColorRect.new()
	shadow.color = Color(0, 0, 0, 0.28)
	shadow.position = center - size * 0.5
	shadow.size = size
	return shadow

func _add_vignette() -> void:
	_add_rect(Vector2(0, 0), Vector2(1280, 32), Color(0, 0, 0, 0.18))
	_add_rect(Vector2(0, 0), Vector2(28, 720), Color(0, 0, 0, 0.18))
	_add_rect(Vector2(1252, 0), Vector2(28, 720), Color(0, 0, 0, 0.18))
	_add_rect(Vector2(0, 688), Vector2(1280, 32), Color(0, 0, 0, 0.18))

func _add_label(text: String, pos: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	add_child(label)

func _move_player(delta: float) -> void:
	var direction := Vector2.ZERO
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		direction.y += 1.0
	if direction.length() > 1.0:
		direction = direction.normalized()
	player_direction = direction
	var target_velocity := direction * PLAYER_SPEED
	player_velocity = player_velocity.lerp(target_velocity, min(1.0, PLAYER_ACCEL * delta))
	if direction == Vector2.ZERO and player_velocity.length() < 2.0:
		player_velocity = Vector2.ZERO

	player_pos += player_velocity * delta
	var map_rect: Rect2 = _current_map_rect()
	player_pos.x = clamp(player_pos.x, map_rect.position.x + 70.0, map_rect.end.x - 110.0)
	player_pos.y = clamp(player_pos.y, 455.0, 620.0)
	_update_player()

func _update_camera() -> void:
	var map_rect: Rect2 = _current_map_rect()
	var desired_x: float = player_pos.x - VIEW_SIZE.x * 0.48
	var min_camera_x: float = map_rect.position.x
	var max_camera_x: float = map_rect.end.x - VIEW_SIZE.x
	if max_camera_x < min_camera_x:
		max_camera_x = min_camera_x
	camera_x = clamp(desired_x, min_camera_x, max_camera_x)
	if world_root != null:
		world_root.position.x = -camera_x
		world_root.position.y = 0.0

func _update_player() -> void:
	if player != null:
		player.position = player_pos + PLAYER_SPRITE_OFFSET
		if player.has_method("set_motion"):
			player.set_motion(player_velocity / PLAYER_SPEED)
	if player_shadow != null:
		player_shadow.position = player_pos + Vector2(14, 43) - player_shadow.size * 0.5

func _find_target() -> void:
	current_target = -1
	var best_distance := 999999.0
	var player_center := player_pos + Vector2(14, 22)
	for i in range(target_defs.size()):
		var target_pos: Vector2 = target_defs[i]["pos"]
		if _map_id_for_position(target_pos) != current_map:
			continue
		var distance := player_center.distance_to(target_pos)
		if distance < INTERACT_RANGE and distance < best_distance:
			current_target = i
			best_distance = distance
	_update_target_highlights()
	_update_labels()

func _update_target_highlights() -> void:
	for i in range(target_nodes.size()):
		var marker = target_nodes[i]
		if marker == null:
			continue
		var active := i == current_target
		marker.scale = Vector2(1.04, 1.04) if active else Vector2.ONE
		for child in marker.get_children():
			if child.has_method("set_highlight"):
				child.set_highlight(active)
	if interaction_prompt != null:
		interaction_prompt.visible = current_target >= 0
		if current_target >= 0:
			interaction_prompt.position = _world_to_screen(target_defs[current_target]["pos"]) + Vector2(-20, -92)

func _interact() -> void:
	if is_transitioning:
		return

	if current_target < 0:
		_show_message(tr_text("move_closer"))
		return

	var target: Dictionary = target_defs[current_target]
	var kind := str(target["kind"])
	if kind == "portal":
		_show_message(str(target["message"]))
		await _teleport_to(target)
		return

	if kind == "warehouse_portal":
		if clues_found >= 2:
			_show_message(str(target["message"]))
			await _teleport_to(target)
		else:
			_show_message(tr_text("warehouse_locked"))
		return

	if kind == "battle":
		_show_message(str(target["message"]))
		await _fade_to_black()
		get_tree().change_scene_to_file("res://scenes/BattleScene.tscn")
		return

	var target_id := str(target["id"])
	if kind == "clue" and not target_done.has(target_id):
		target_done[target_id] = true
		clues_found += 1
		_show_message(str(target["message"]))
	else:
		_show_message(_talk_message(current_target) + "\n" + _next_objective_message())
	_update_labels()

func _teleport_to(target: Dictionary) -> void:
	is_transitioning = true
	current_target = -1
	_update_target_highlights()
	await _fade_screen(0.0, TELEPORT_FADE_ALPHA, TELEPORT_FADE_IN_SECONDS)

	var destination: Vector2 = target["to"]
	current_map = _map_id_for_position(destination)
	player_pos = _safe_landing_position(destination)
	player_velocity = Vector2.ZERO
	_update_player()
	_update_camera()
	await get_tree().process_frame
	_find_target()
	await _fade_screen(TELEPORT_FADE_ALPHA, 0.0, TELEPORT_FADE_OUT_SECONDS)
	is_transitioning = false

func _safe_landing_position(destination: Vector2) -> Vector2:
	var landing := destination
	var destination_map := _map_id_for_position(destination)
	for target in target_defs:
		var target_pos: Vector2 = target["pos"]
		if _map_id_for_position(target_pos) != destination_map:
			continue
		var kind := str(target["kind"])
		if landing.distance_to(target_pos) < INTERACT_RANGE and (kind == "portal" or kind == "warehouse_portal"):
			var push_dir := landing - target_pos
			if push_dir.length() < 1.0:
				push_dir = Vector2.RIGHT
			landing = target_pos + push_dir.normalized() * TELEPORT_EXIT_PUSH
			break
	var map_rect: Rect2 = MAP_RECTS[destination_map]
	landing.x = clamp(landing.x, map_rect.position.x + 70.0, map_rect.end.x - 110.0)
	landing.y = clamp(landing.y, 455.0, 620.0)
	return landing

func _current_map_rect() -> Rect2:
	if MAP_RECTS.has(current_map):
		return MAP_RECTS[current_map]
	return MAP_RECTS["west_market"]

func _map_id_for_position(pos: Vector2) -> String:
	for map_id in MAP_RECTS.keys():
		var rect: Rect2 = MAP_RECTS[map_id]
		if rect.has_point(pos):
			return str(map_id)
	return "west_market"

func _fade_screen(from_alpha: float, to_alpha: float, duration: float) -> void:
	if fade_overlay == null:
		await get_tree().create_timer(duration).timeout
		return
	fade_overlay.color = Color(0, 0, 0, from_alpha)
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, to_alpha), duration)
	await tween.finished

func _fade_to_black() -> void:
	if fade_overlay == null:
		await get_tree().create_timer(0.35).timeout
		return
	fade_overlay.color = Color(0, 0, 0, 0)
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color", Color(0, 0, 0, 1), 0.42)
	await tween.finished

func _clue_message(index: int) -> String:
	if index == 0:
		return tr_text("clue_vendor")
	if index == 1:
		return tr_text("clue_porter")
	if index == 2:
		return tr_text("clue_performer")
	return tr_text("clue_scene")

func _talk_message(index: int) -> String:
	var target_id := str(target_defs[index]["id"])
	if target_id == "spice_vendor":
		return tr_text("talk_vendor")
	if target_id == "tea_porter":
		return tr_text("talk_porter")
	if target_id == "music_performer":
		return tr_text("talk_performer")
	if target_id == "scene_body":
		return tr_text("talk_scene")
	return "这里暂时没有新的发现。"

func _update_labels() -> void:
	if hint_label == null or clue_label == null:
		return
	if current_target >= 0:
		var target_id := str(target_defs[current_target]["id"])
		if target_done.has(target_id) and str(target_defs[current_target]["kind"]) == "clue":
			hint_label.text = format_text(tr_text("checked_hint"), {"name": target_name(current_target)})
		else:
			hint_label.text = format_text(tr_text("interact_hint"), {"name": target_name(current_target)})
	else:
		hint_label.text = tr_text("move_hint")
	clue_label.text = format_text(tr_text("clue_count"), {"found": str(clues_found), "needed": "2"})

func _next_objective_message() -> String:
	if clues_found < 2:
		return tr_text("already_checked_more")
	return tr_text("already_checked_done")

func _show_message(message: String) -> void:
	if dialogue_label != null:
		dialogue_label.clear()
		dialogue_label.append_text(message)
	if dialogue_balloon != null:
		if current_target >= 0 and current_target != 4:
			dialogue_balloon.visible = true
			var target_pos: Vector2 = target_defs[current_target]["pos"]
			var screen_target: Vector2 = _world_to_screen(target_pos)
			var desired_x: float = screen_target.x - dialogue_balloon.size.x * 0.5
			var desired_y: float = screen_target.y - dialogue_balloon.size.y - 70.0
			desired_x = clamp(desired_x, 70.0, 850.0)
			desired_y = clamp(desired_y, 120.0, 390.0)
			dialogue_balloon.position = Vector2(desired_x, desired_y)
			var tail_x: float = (screen_target.x - desired_x) / dialogue_balloon.size.x
			var speaker := target_name(current_target)
			var clean_message := message.replace("\n", " ")
			dialogue_balloon.set_dialogue(speaker, clean_message, tail_x)
		else:
			dialogue_balloon.visible = false

func _world_to_screen(world_pos: Vector2) -> Vector2:
	return Vector2(world_pos.x - camera_x, world_pos.y)

func _stylebox(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	return style

func target_name(index: int) -> String:
	return str(target_defs[index]["name"])

func tr_text(key: String) -> String:
	if text_data.has(key):
		return str(text_data[key])
	return key

func format_text(template: String, values: Dictionary) -> String:
	var result := template
	for key in values.keys():
		result = result.replace("{" + str(key) + "}", str(values[key]))
	return result

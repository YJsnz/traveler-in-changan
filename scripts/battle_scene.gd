extends Control

const HeroSprite := preload("res://scripts/hero_sprite.gd")
const BattleHeroSprite := preload("res://scripts/battle_hero_sprite.gd")
const EnemySprite := preload("res://scripts/battle_enemy_sprite.gd")
const BATTLE_BG := "res://assets/maps/west-market-battle-bg.png"
const PLAYER_MAX_HP := 120
const ENEMY_MAX_HP := 90
const ENEMY_MAX_SHIELD := 2

var player_hp := PLAYER_MAX_HP
var player_bp := 1
var enemy_hp := ENEMY_MAX_HP
var enemy_shield := ENEMY_MAX_SHIELD
var enemy_broken_turns := 0
var is_guarding := false
var is_animating := false

var status_label: Label
var enemy_label: Label
var log_label: RichTextLabel
var attack_button: Button
var fire_button: Button
var boost_button: Button
var guard_button: Button
var restart_button: Button
var enemy_hp_bar: ColorRect
var player_hp_bar: ColorRect
var player_bp_pips: Array = []
var shield_pips: Array = []
var command_buttons: Array[Button] = []
var hero_actor: Control
var enemy_actors: Array[Control] = []
var effect_layer: Control
var hero_home := Vector2.ZERO
var enemy_homes: Array[Vector2] = []

func _ready() -> void:
	_build_ui()
	_update_status()
	_log(txt("A bandit blocks the constable in the West Market alley."))

func _build_ui() -> void:
	_add_background()
	_add_stage_frame()
	_add_turn_order()
	_add_enemy_group()
	_add_player_group()
	_add_effect_layer()
	_add_right_commands()
	_add_bottom_status()
	_add_log_panel()

func _add_background() -> void:
	var bg := TextureRect.new()
	var image := Image.new()
	if image.load(BATTLE_BG) == OK:
		bg.texture = ImageTexture.create_from_image(image)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = 1
	bg.stretch_mode = 6
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.025, 0.035, 0.26)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

func _add_stage_frame() -> void:
	var top := ColorRect.new()
	top.color = Color(0, 0, 0, 0.18)
	top.position = Vector2(0, 0)
	top.size = Vector2(1280, 52)
	add_child(top)
	_add_border_line(Vector2(14, 14), Vector2(1252, 0))
	_add_border_line(Vector2(14, 706), Vector2(1252, 0))
	_add_border_line(Vector2(14, 14), Vector2(0, 692))
	_add_border_line(Vector2(1266, 14), Vector2(0, 692))

	var title := Label.new()
	title.text = txt("West Market Lights Out")
	title.position = Vector2(44, 18)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color("#f2e6cf"))
	add_child(title)

func _add_turn_order() -> void:
	var start := Vector2(350, 34)
	for i in range(6):
		var is_player := i == 0 or i == 3
		_add_turn_icon(start + Vector2(i * 47, 0), is_player, i == 0)

func _add_enemy_group() -> void:
	_add_battle_shadow(Vector2(310, 482), Vector2(138, 22))
	_add_battle_shadow(Vector2(470, 492), Vector2(118, 18))
	var enemy_a := EnemySprite.new()
	enemy_a.setup(Rect2(48, 234, 801, 596), 0.0)
	enemy_a.position = Vector2(210, 250)
	enemy_a.size = Vector2(240, 265)
	add_child(enemy_a)
	enemy_actors.append(enemy_a)
	enemy_homes.append(enemy_a.position)
	var enemy_b := EnemySprite.new()
	enemy_b.setup(Rect2(850, 59, 825, 769), 1.1)
	enemy_b.position = Vector2(395, 250)
	enemy_b.size = Vector2(205, 260)
	add_child(enemy_b)
	enemy_actors.append(enemy_b)
	enemy_homes.append(enemy_b.position)

	enemy_label = Label.new()
	enemy_label.position = Vector2(205, 532)
	enemy_label.custom_minimum_size = Vector2(420, 30)
	enemy_label.add_theme_font_size_override("font_size", 16)
	enemy_label.add_theme_color_override("font_color", Color("#f2e6cf"))
	add_child(enemy_label)

	enemy_hp_bar = _make_bar(Vector2(270, 568), Vector2(190, 7), Color("#b2322b"))
	add_child(enemy_hp_bar)
	for i in range(ENEMY_MAX_SHIELD):
		var pip := _make_pip(Vector2(270 + i * 22, 590), Color("#8b6f3d"))
		shield_pips.append(pip)
		add_child(pip)

func _add_player_group() -> void:
	_add_battle_shadow(Vector2(805, 510), Vector2(140, 22))
	var hero := BattleHeroSprite.new()
	hero.position = Vector2(755, 336)
	hero.size = Vector2(94, 184)
	hero.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hero)
	hero_actor = hero
	hero_home = hero.position

	var portrait := ColorRect.new()
	portrait.position = Vector2(1058, 56)
	portrait.size = Vector2(86, 86)
	portrait.color = Color(0.05, 0.055, 0.065, 0.72)
	add_child(portrait)
	_add_border_rect(portrait.position, portrait.size, Color("#8b6f3d"))

	var small := BattleHeroSprite.new()
	small.position = Vector2(1074, 62)
	small.size = Vector2(42, 74)
	add_child(small)

	status_label = Label.new()
	status_label.position = Vector2(1060, 150)
	status_label.custom_minimum_size = Vector2(190, 70)
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", Color("#f2e6cf"))
	add_child(status_label)

	player_hp_bar = _make_bar(Vector2(1060, 222), Vector2(150, 8), Color("#b2322b"))
	add_child(player_hp_bar)
	player_bp_pips.clear()
	for i in range(5):
		var pip := _make_pip(Vector2(1060 + i * 24, 244), Color("#d9903d"))
		player_bp_pips.append(pip)
		add_child(pip)

func _add_effect_layer() -> void:
	effect_layer = Control.new()
	effect_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	effect_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(effect_layer)

func _add_right_commands() -> void:
	var panel := PanelContainer.new()
	panel.position = Vector2(1015, 310)
	panel.custom_minimum_size = Vector2(230, 260)
	panel.add_theme_stylebox_override("panel", _stylebox(Color(0.055, 0.055, 0.055, 0.72), Color("#8b6f3d"), 1))
	add_child(panel)

	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	panel.add_child(actions)
	attack_button = _make_button("01  " + txt("Blade"), _on_attack_pressed)
	fire_button = _make_button("02  " + txt("Fire Charm"), _on_fire_pressed)
	boost_button = _make_button("03  " + txt("Boost"), _on_boost_pressed)
	guard_button = _make_button("04  " + txt("Guard"), _on_guard_pressed)
	restart_button = _make_button("05  " + txt("Restart"), _on_restart_pressed)
	actions.add_child(attack_button)
	actions.add_child(fire_button)
	actions.add_child(boost_button)
	actions.add_child(guard_button)
	actions.add_child(restart_button)

func _add_bottom_status() -> void:
	var strip := ColorRect.new()
	strip.color = Color(0.02, 0.02, 0.022, 0.54)
	strip.position = Vector2(0, 570)
	strip.size = Vector2(1280, 150)
	add_child(strip)

func _add_log_panel() -> void:
	log_label = RichTextLabel.new()
	log_label.bbcode_enabled = true
	log_label.position = Vector2(385, 595)
	log_label.size = Vector2(560, 76)
	log_label.add_theme_color_override("default_color", Color("#f2e6cf"))
	log_label.add_theme_stylebox_override("normal", _stylebox(Color(0.04, 0.045, 0.055, 0.78), Color("#5f8a75"), 1))
	add_child(log_label)

func _make_bar(pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var back := ColorRect.new()
	back.position = pos
	back.size = size
	back.color = Color(0.05, 0.045, 0.04, 0.9)
	add_child(back)
	var fill := ColorRect.new()
	fill.position = pos + Vector2(1, 1)
	fill.size = size - Vector2(2, 2)
	fill.color = color
	return fill

func _make_pip(pos: Vector2, color: Color) -> ColorRect:
	var pip := ColorRect.new()
	pip.position = pos
	pip.size = Vector2(14, 14)
	pip.rotation = 0.785
	pip.color = color
	return pip

func _add_turn_icon(pos: Vector2, is_player: bool, active: bool) -> void:
	var icon := Control.new()
	icon.position = pos
	icon.size = Vector2(38, 38)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func() -> void:
		var center := Vector2(19, 19)
		var diamond := PackedVector2Array([
			Vector2(19, 0),
			Vector2(38, 19),
			Vector2(19, 38),
			Vector2(0, 19),
		])
		var fill := Color("#233446") if active else Color("#151820")
		icon.draw_colored_polygon(diamond, fill)
		icon.draw_polyline(PackedVector2Array([Vector2(19, 0), Vector2(38, 19), Vector2(19, 38), Vector2(0, 19), Vector2(19, 0)]), Color("#9b743d"), 1.4)
		if is_player:
			icon.draw_rect(Rect2(center + Vector2(-6, -9), Vector2(12, 10)), Color("#d3a477"))
			icon.draw_rect(Rect2(center + Vector2(-9, -14), Vector2(18, 6)), Color("#17120f"))
			icon.draw_rect(Rect2(center + Vector2(-8, 2), Vector2(16, 14)), Color("#242026"))
			icon.draw_rect(Rect2(center + Vector2(-6, 4), Vector2(12, 5)), Color("#8b6f3d"))
			icon.draw_line(center + Vector2(-12, 7), center + Vector2(-19, 13), Color("#d9903d"), 2.0)
		else:
			icon.draw_rect(Rect2(center + Vector2(-14, -11), Vector2(28, 6)), Color("#6b5537"))
			icon.draw_rect(Rect2(center + Vector2(-5, -7), Vector2(10, 9)), Color("#d2a272"))
			icon.draw_rect(Rect2(center + Vector2(-8, 2), Vector2(16, 15)), Color("#3c332b"))
			icon.draw_rect(Rect2(center + Vector2(-9, 5), Vector2(18, 4)), Color("#4d4a36"))
			icon.draw_line(center + Vector2(-10, 5), center + Vector2(-20, 13), Color("#c98a46"), 2.0)
	)
	add_child(icon)

func _add_battle_shadow(center: Vector2, size: Vector2) -> void:
	var shadow := ColorRect.new()
	shadow.position = center - size * 0.5
	shadow.size = size
	shadow.color = Color(0, 0, 0, 0.30)
	add_child(shadow)

func _add_border_line(pos: Vector2, delta: Vector2) -> void:
	var line := ColorRect.new()
	line.position = pos
	line.size = Vector2(max(1.0, abs(delta.x)), max(1.0, abs(delta.y)))
	line.color = Color("#8b6f3d")
	add_child(line)

func _add_border_rect(pos: Vector2, rect_size: Vector2, color: Color) -> void:
	var top := ColorRect.new()
	top.position = pos
	top.size = Vector2(rect_size.x, 1)
	top.color = color
	add_child(top)
	var bottom := ColorRect.new()
	bottom.position = pos + Vector2(0, rect_size.y)
	bottom.size = Vector2(rect_size.x, 1)
	bottom.color = color
	add_child(bottom)
	var left := ColorRect.new()
	left.position = pos
	left.size = Vector2(1, rect_size.y)
	left.color = color
	add_child(left)
	var right := ColorRect.new()
	right.position = pos + Vector2(rect_size.x, 0)
	right.size = Vector2(1, rect_size.y)
	right.color = color
	add_child(right)

func _stylebox(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(width)
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

func _make_button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(205, 40)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color("#f2e6cf"))
	button.add_theme_color_override("font_hover_color", Color("#fff3d8"))
	button.add_theme_color_override("font_pressed_color", Color("#ffffff"))
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.50, 0.43, 0.75))
	button.add_theme_stylebox_override("normal", _button_style(Color(0.045, 0.042, 0.040, 0.84), Color("#4f4230")))
	button.add_theme_stylebox_override("hover", _button_style(Color(0.16, 0.12, 0.075, 0.92), Color("#d9903d")))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.22, 0.15, 0.07, 0.96), Color("#f0b35a")))
	button.add_theme_stylebox_override("focus", _button_style(Color(0.08, 0.075, 0.065, 0.85), Color("#f0b35a")))
	button.add_theme_stylebox_override("disabled", _button_style(Color(0.035, 0.032, 0.030, 0.55), Color("#30281f")))
	button.mouse_entered.connect(func() -> void:
		button.grab_focus()
	)
	button.pressed.connect(callback)
	command_buttons.append(button)
	return button

func _button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 2
	style.corner_radius_top_right = 2
	style.corner_radius_bottom_left = 2
	style.corner_radius_bottom_right = 2
	style.content_margin_left = 18
	style.content_margin_right = 14
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

func _on_attack_pressed() -> void:
	await _player_action(txt("Blade"), 16, true, "slash")

func _on_fire_pressed() -> void:
	await _player_action(txt("Fire Charm"), 12, true, "fire")

func _on_boost_pressed() -> void:
	if is_animating:
		return
	if player_bp <= 0:
		_log(txt("Not enough BP to boost."))
		return
	player_bp -= 1
	_update_status()
	await _player_action(txt("Boosted Blade"), 32, true, "boost_slash")

func _on_guard_pressed() -> void:
	if is_animating:
		return
	is_guarding = true
	_log(txt("The constable guards and reduces the next hit."))
	_set_actions_enabled(false)
	is_animating = true
	await _play_guard_animation()
	await _enemy_turn()
	is_animating = false
	if player_hp > 0 and enemy_hp > 0:
		_set_actions_enabled(true)

func _on_restart_pressed() -> void:
	player_hp = PLAYER_MAX_HP
	player_bp = 1
	enemy_hp = ENEMY_MAX_HP
	enemy_shield = ENEMY_MAX_SHIELD
	enemy_broken_turns = 0
	is_guarding = false
	log_label.clear()
	_set_actions_enabled(true)
	_update_status()
	_log(txt("Battle restarted."))

func _player_action(action_name: String, damage: int, hits_weakness: bool, anim_kind: String) -> void:
	if enemy_hp <= 0 or player_hp <= 0 or is_animating:
		return
	is_animating = true
	_set_actions_enabled(false)

	var final_damage := damage
	if enemy_broken_turns > 0:
		final_damage = int(final_damage * 1.5)
	elif hits_weakness:
		enemy_shield -= 1
		_log(txt("%s hits a weakness. Bandit shield -1.") % action_name)
		if enemy_shield <= 0:
			enemy_broken_turns = 1
			enemy_shield = 0
			_log(txt("The bandit is broken. Damage is increased."))

	if anim_kind == "boost_slash":
		await _play_boost_animation()
		await _play_slash_animation()
	elif anim_kind == "fire":
		await _play_fire_animation()
	else:
		await _play_slash_animation()

	enemy_hp = max(enemy_hp - final_damage, 0)
	_log(txt("Constable uses %s for %d damage.") % [action_name, final_damage])
	_update_status()
	await _play_enemy_hit_animation()

	if enemy_hp <= 0:
		_log("[color=gold]" + txt("The bandit falls. You find a torn frontier letter.") + "[/color]")
		_set_actions_enabled(false)
		_update_status()
		is_animating = false
		return

	await _enemy_turn()
	is_animating = false
	if player_hp > 0 and enemy_hp > 0:
		_set_actions_enabled(true)

func _enemy_turn() -> void:
	if enemy_hp <= 0:
		return

	var damage := 14
	if is_guarding:
		damage = 7
		is_guarding = false

	await _play_enemy_counter_animation()
	player_hp = max(player_hp - damage, 0)
	_log(txt("Bandit counters for %d damage.") % damage)
	_update_status()
	await _play_player_hit_animation()

	if enemy_broken_turns > 0:
		enemy_broken_turns -= 1
		if enemy_broken_turns == 0:
			enemy_shield = ENEMY_MAX_SHIELD
			_log(txt("The bandit recovers and resets shield."))

	if player_hp <= 0:
		_log("[color=red]" + txt("The constable falls. The trail goes cold.") + "[/color]")
		_set_actions_enabled(false)
	else:
		player_bp = min(player_bp + 1, 5)

	_update_status()

func _play_slash_animation() -> void:
	var dash: Tween = create_tween()
	dash.tween_property(hero_actor, "position", hero_home + Vector2(-58, -3), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	dash.tween_property(hero_actor, "position", hero_home, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await dash.finished
	await _spawn_slash(Vector2(365, 420), -0.48, Color("#f0b35a"))

func _play_fire_animation() -> void:
	var start_pos := hero_actor.position + Vector2(20, 65)
	var end_pos := Vector2(380, 410)
	var charm := ColorRect.new()
	charm.position = start_pos
	charm.size = Vector2(18, 18)
	charm.rotation = 0.785
	charm.color = Color("#f0b35a")
	effect_layer.add_child(charm)
	var fly: Tween = create_tween()
	fly.tween_property(charm, "position", end_pos, 0.34).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	fly.parallel().tween_property(charm, "modulate", Color(1.0, 0.45, 0.12, 0.0), 0.34)
	await fly.finished
	charm.queue_free()
	await _spawn_flash(end_pos + Vector2(10, 10), 70.0, Color(1.0, 0.32, 0.08, 0.48))

func _play_boost_animation() -> void:
	await _spawn_flash(hero_actor.position + Vector2(48, 98), 82.0, Color(0.95, 0.67, 0.20, 0.34))
	var glow: Tween = create_tween()
	glow.tween_property(hero_actor, "modulate", Color(1.45, 1.18, 0.72, 1.0), 0.10)
	glow.tween_property(hero_actor, "modulate", Color.WHITE, 0.18)
	await glow.finished

func _play_guard_animation() -> void:
	var shield := Control.new()
	shield.position = hero_actor.position + Vector2(-14, 14)
	shield.size = Vector2(120, 160)
	shield.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shield.draw.connect(func() -> void:
		shield.draw_arc(Vector2(60, 80), 58.0, -1.3, 1.3, 24, Color(0.62, 0.86, 1.0, 0.62), 4.0)
		shield.draw_arc(Vector2(60, 80), 44.0, -1.2, 1.2, 24, Color(0.95, 0.86, 0.48, 0.38), 2.0)
	)
	effect_layer.add_child(shield)
	var tw: Tween = create_tween()
	tw.tween_property(shield, "scale", Vector2(1.08, 1.08), 0.16)
	tw.parallel().tween_property(shield, "modulate", Color(1, 1, 1, 0.0), 0.34)
	await tw.finished
	shield.queue_free()

func _play_enemy_hit_animation() -> void:
	var shake: Tween = create_tween()
	shake.set_parallel(true)
	for i in range(enemy_actors.size()):
		var actor: Control = enemy_actors[i]
		var home: Vector2 = enemy_homes[i]
		shake.tween_property(actor, "position", home + Vector2(-10, 0), 0.05)
		shake.tween_property(actor, "modulate", Color(1.45, 0.35, 0.28, 1.0), 0.05)
	await shake.finished
	var settle: Tween = create_tween()
	settle.set_parallel(true)
	for i in range(enemy_actors.size()):
		var actor: Control = enemy_actors[i]
		var home: Vector2 = enemy_homes[i]
		settle.tween_property(actor, "position", home, 0.12)
		settle.tween_property(actor, "modulate", Color.WHITE, 0.12)
	await settle.finished

func _play_player_hit_animation() -> void:
	var hit: Tween = create_tween()
	hit.tween_property(hero_actor, "position", hero_home + Vector2(18, 0), 0.05)
	hit.parallel().tween_property(hero_actor, "modulate", Color(1.55, 0.35, 0.32, 1.0), 0.05)
	hit.tween_property(hero_actor, "position", hero_home, 0.13)
	hit.parallel().tween_property(hero_actor, "modulate", Color.WHITE, 0.13)
	await hit.finished

func _play_enemy_counter_animation() -> void:
	if enemy_actors.is_empty():
		return
	var attacker: Control = enemy_actors[1] if enemy_actors.size() > 1 else enemy_actors[0]
	var home: Vector2 = attacker.position
	var step: Tween = create_tween()
	step.tween_property(attacker, "position", home + Vector2(58, -2), 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await step.finished
	await _spawn_slash(hero_actor.position + Vector2(44, 82), 0.42, Color("#d8d0bf"))
	var back: Tween = create_tween()
	back.tween_property(attacker, "position", home, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await back.finished

func _spawn_slash(center: Vector2, angle: float, color: Color) -> void:
	var slash := ColorRect.new()
	slash.position = center - Vector2(72, 4)
	slash.size = Vector2(144, 8)
	slash.rotation = angle
	slash.color = color
	slash.modulate = Color(1, 1, 1, 0.95)
	effect_layer.add_child(slash)
	var tw: Tween = create_tween()
	tw.tween_property(slash, "scale", Vector2(1.18, 1.0), 0.06)
	tw.parallel().tween_property(slash, "modulate", Color(1, 1, 1, 0.0), 0.16)
	await tw.finished
	slash.queue_free()

func _spawn_flash(center: Vector2, radius: float, color: Color) -> void:
	var flash := Control.new()
	flash.position = center - Vector2(radius, radius)
	flash.size = Vector2(radius * 2.0, radius * 2.0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.draw.connect(func() -> void:
		flash.draw_circle(Vector2(radius, radius), radius, color)
		flash.draw_circle(Vector2(radius, radius), radius * 0.48, Color(1.0, 0.88, 0.44, 0.44))
	)
	effect_layer.add_child(flash)
	var tw: Tween = create_tween()
	flash.scale = Vector2(0.45, 0.45)
	tw.tween_property(flash, "scale", Vector2(1.15, 1.15), 0.18)
	tw.parallel().tween_property(flash, "modulate", Color(1, 1, 1, 0.0), 0.22)
	await tw.finished
	flash.queue_free()

func _update_status() -> void:
	var broken_text := txt("Broken") if enemy_broken_turns > 0 else txt("Ready")
	status_label.text = "%s\nHP %d/%d   BP %d/5" % [
		txt("Constable"),
		player_hp,
		PLAYER_MAX_HP,
		player_bp,
	]
	enemy_label.text = "%s HP %d/%d    %s %d/%d    %s: %s    %s: %s" % [
		txt("Bandit"),
		enemy_hp,
		ENEMY_MAX_HP,
		txt("Shield"),
		enemy_shield,
		ENEMY_MAX_SHIELD,
		txt("State"),
		broken_text,
		txt("Weakness"),
		txt("Blade, Fire"),
	]
	if enemy_hp_bar != null:
		enemy_hp_bar.size.x = 188.0 * float(enemy_hp) / float(ENEMY_MAX_HP)
	if player_hp_bar != null:
		player_hp_bar.size.x = 148.0 * float(player_hp) / float(PLAYER_MAX_HP)
	for i in range(player_bp_pips.size()):
		player_bp_pips[i].color = Color("#d9903d") if i < player_bp else Color(0.25, 0.22, 0.18, 0.75)
	for i in range(shield_pips.size()):
		shield_pips[i].color = Color("#8b6f3d") if i < enemy_shield else Color(0.25, 0.22, 0.18, 0.75)

func _set_actions_enabled(enabled: bool) -> void:
	attack_button.disabled = not enabled
	fire_button.disabled = not enabled
	boost_button.disabled = not enabled
	guard_button.disabled = not enabled

func _log(message: String) -> void:
	log_label.append_text(message + "\n")

func txt(key: String) -> String:
	var strings := {
		"West Market Lights Out": [35199, 24066, 28783, 28781],
		"Constable": [19981, 33391, 20154],
		"Bandit": [30423, 21290],
		"Blade": [20992, 20987],
		"Fire Charm": [28779, 31526],
		"Boost": [22686, 24133],
		"Guard": [38450, 24481],
		"Restart": [37325, 24320],
		"Boosted Blade": [22686, 24133, 20992, 20987],
		"Shield": [25252, 30462],
		"State": [29366, 24577],
		"Weakness": [24369, 28857],
		"Blade, Fire": [20992, 12289, 28779],
		"Broken": [30772, 38450],
		"Ready": [26410, 30772, 38450],
		"Not enough BP to boost.": [66, 80, 19981, 36275, 65292, 26080, 27861, 22686, 24133, 12290],
		"A bandit blocks the constable in the West Market alley.": [35199, 24066, 21518, 24055, 65292, 30423, 21290, 25318, 20303, 20102, 19981, 33391, 20154, 30340, 21435, 36335, 12290],
		"The constable guards and reduces the next hit.": [19981, 33391, 20154, 27178, 20992, 38450, 24481, 65292, 26412, 22238, 21512, 21463, 21040, 30340, 20260, 23475, 20943, 21322, 12290],
		"Battle restarted.": [25112, 26007, 37325, 24320, 12290],
		"%s hits a weakness. Bandit shield -1.": [37, 115, 20987, 20013, 24369, 28857, 65292, 30423, 21290, 25252, 30462, 32, 45, 49, 12290],
		"The bandit is broken. Damage is increased.": [30423, 21290, 30772, 38450, 65292, 21463, 20260, 25552, 21319, 12290],
		"Constable uses %s for %d damage.": [19981, 33391, 20154, 20351, 29992, 37, 115, 65292, 36896, 25104, 32, 37, 100, 32, 28857, 20260, 23475, 12290],
		"The bandit falls. You find a torn frontier letter.": [30423, 21290, 20498, 19979, 12290, 20320, 22312, 20182, 36523, 19978, 25214, 21040, 21322, 25130, 20891, 38215, 30340, 36793, 38215, 23494, 20449, 12290],
		"Bandit counters for %d damage.": [30423, 21290, 21453, 20987, 65292, 36896, 25104, 32, 37, 100, 32, 28857, 20260, 23475, 12290],
		"The bandit recovers and resets shield.": [30423, 21290, 24674, 22797, 26550, 21183, 65292, 25252, 30462, 37325, 32622, 12290],
		"The constable falls. The trail goes cold.": [19981, 33391, 20154, 21147, 31469, 20498, 19979, 65292, 32447, 32034, 26029, 20102, 12290],
	}
	if not strings.has(key):
		return key
	return _from_codepoints(strings[key])

func _from_codepoints(codes: Array) -> String:
	var out := ""
	for code in codes:
		out += String.chr(int(code))
	return out

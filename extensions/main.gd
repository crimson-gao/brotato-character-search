extends CharacterSelection

signal character_search_text_changed(value)

var _search_bar:LineEdit
var search_ui:PanelContainer

var _search_bar_filtered_elements = []

const MOD_NAME = "Crimson-CharacterSearch"
const _search_bar_container_max_width = 240
const _search_bar_container_max_height = 40
const _search_bar_default_hint_width = 115
var _search_bar_margin_width = 0
var _search_bar_font
var _search_ui_enable = true
var _search_config:ModConfig = null
var _search_config_dict:Dictionary = {}
const CONFIG_NAME = "config-1"

		
# Called when the node enters the scene tree for the first time.
func _ready():
		
	search_ui = preload("res://mods-unpacked/Crimson-CharacterSearch/extensions/search_bar.tscn").instance()
	self.add_child(search_ui)
	
	_search_bar = search_ui.get_node("MarginContainer/LineEdit")
	_search_bar.connect("text_changed", self, "on_character_search_text_changed")
	reset_size_and_position()
	
	load_config()
	apply_config(_search_config.data)

	update_search_bar_visiable()
		
	if search_ui.visible:
		do_filter("")
		
func reset_size_and_position():
	_search_bar_font = _search_bar.get_font("font")
	_search_bar_margin_width = _search_bar_default_hint_width - _search_bar_font.get_string_size("search").x
	var container = $MarginContainer / VBoxContainer / ScrollContainer
	var pos = container.rect_position
	search_ui.rect_position = Vector2(164, pos[1])
	search_ui.rect_size = calc_search_bar_width("")

func calc_search_bar_width(value: String):
	var text_width = _search_bar_font.get_string_size(value).x
	text_width = min(text_width, _search_bar_container_max_width - _search_bar_margin_width - 10)
	var final_width = max(_search_bar_default_hint_width, text_width + _search_bar_margin_width + 10)
	return Vector2(final_width, _search_bar_container_max_height)


func load_config():
	_search_config = ModLoaderConfig.get_config(MOD_NAME, CONFIG_NAME)		
	if not _search_config:
		_search_config = ModLoaderConfig.get_default_config(MOD_NAME)
	_search_config_dict = _search_config.data.duplicate()

func merge_with_default_config(config:ModConfig, default_config:ModConfig)->bool:
	var update = false
	for key in default_config.data.keys():
		if not config.data.has(key):
			update = true
			config.data[key] = default_config.data[key]
	return update
	
func apply_config(config:Dictionary):
	_search_ui_enable = config["CS_ENABLE"]
	search_ui.rect_position += Vector2(config["CS_POS_X_OFFSET"] *100, config["CS_POS_Y_OFFSET"] *100)
	search_ui.rect_scale.x *= config["CS_SIZE_X_SCALE"]
	search_ui.rect_scale.y *= config["CS_SIZE_Y_SCALE"]			

	
func update_search_bar_visiable():
	if _search_ui_enable && !search_ui.visible && is_character_selection_scene():
		search_ui.show()
		return
		
	if search_ui.visible && (!_search_ui_enable || !is_character_selection_scene()):
		search_ui.hide()
		
func is_character_selection_scene()->bool:
	return get_tree().current_scene.get_filename() == MenuData.character_selection_scene

	
func do_filter(value:String):
	_inventory.clear_elements()
	if value == "":
		_search_bar_filtered_elements = available_elements.duplicate()	
	else:
		_search_bar_filtered_elements = []
		for ele in available_elements: # filter by localized name or English name
			var name: String = ele.name
			var v = value.to_lower()
			if v in name.to_lower() || v in tr(name):
				_search_bar_filtered_elements.append(ele)
				
	if _search_bar_filtered_elements.size() > 1 and add_random_element:
		_inventory.add_special_element(random_icon, true)
	_inventory.set_elements(_search_bar_filtered_elements, false, false)
	
func on_character_search_text_changed(value: String):
	search_ui.rect_size = calc_search_bar_width(value)
	emit_signal("character_search_text_changed", value)
	do_filter(value)

# random choose character from filtered elements
func on_element_pressed(element:InventoryElement)->void :
	if !character_added && element.is_random:
		character_added = true
		RunData.add_character(Utils.get_rand_element(_search_bar_filtered_elements))
	else:
		.on_element_pressed(element)







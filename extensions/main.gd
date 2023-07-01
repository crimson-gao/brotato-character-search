extends CharacterSelection

signal character_search_text_changed(value)

var search_bar:LineEdit
var search_bar_container:PanelContainer

var filtered_elements = []

const container_max_width = 240
const container_max_height = 40
const default_hint_width = 115
var margin_width = 0
var font

	
# Called when the node enters the scene tree for the first time.
func _ready():
	search_bar_container = preload("res://mods-unpacked/Crimson-CharacterSearch/extensions/search_bar.tscn").instance()
	self.add_child(search_bar_container)
	
	search_bar = search_bar_container.get_node("MarginContainer/LineEdit")
	search_bar.connect("text_changed", self, "on_character_search_text_changed")
	set_size_and_position()
	
	# 仅在选人时出现
	if get_tree().current_scene.get_filename() == MenuData.character_selection_scene:
		do_filter("")
	else:
		search_bar_container.hide()
	
func do_filter(value:String):
	_inventory.clear_elements()
	if value == "":
		filtered_elements = available_elements.duplicate()	
	else:
		filtered_elements = []
		for ele in available_elements: # filter by localized name or English name
			var name: String = ele.name
			var v = value.to_lower()
			if v in name.to_lower() || v in tr(name):
				filtered_elements.append(ele)
				
	if filtered_elements.size() > 1 and add_random_element:
		_inventory.add_special_element(random_icon, true)

	ModLoaderLog.info(str(filtered_elements.size()), "CharacterSearch");
	_inventory.set_elements(filtered_elements, false, false)
	
func on_character_search_text_changed(value: String):
	search_bar_container.rect_size = calc_search_bar_width(value)
	emit_signal("character_search_text_changed", value)
	do_filter(value)


# random choose character from filtered elements
func on_element_pressed(element:InventoryElement)->void :
	if !character_added && element.is_random:
		character_added = true
		RunData.add_character(Utils.get_rand_element(filtered_elements))
	else:
		.on_element_pressed(element)


func calc_search_bar_width(value: String):
	var text_width = font.get_string_size(value).x
	text_width = min(text_width, container_max_width - margin_width - 10)
	var final_width = max(default_hint_width, text_width + margin_width + 10)
	return Vector2(final_width, container_max_height)

func set_size_and_position():
	font = search_bar.get_font("font")
	margin_width = default_hint_width - font.get_string_size("search").x
	var container = $MarginContainer / VBoxContainer / ScrollContainer
	var pos = container.rect_position
	search_bar_container.rect_position = Vector2(164, pos[1])
	search_bar_container.rect_size = calc_search_bar_width("")

extends Node



const MOD_NAME = "Crimson-CharacterSearch"
var _search_config:ModConfig = null
var _search_config_dict:Dictionary = {}
const CONFIG_NAME = "config-1"

# Called when the node enters the scene tree for the first time.
func _ready():
	load_config()
	watch_config_change() # Replace with function body.


func watch_config_change():
	var ModsConfigInterface = get_node_or_null("/root/ModLoader/dami-ModOptions/ModsConfigInterface")
	if ModsConfigInterface:
		ModsConfigInterface.connect("setting_changed", self, "_on_setting_changed")
		
func _on_setting_changed(name, value, mod_name):
	if mod_name != MOD_NAME:
		return
	ModLoaderLog.info("config settings changed", "CharacterSearch")
	_search_config_dict[name] = value
	_search_config.data = _search_config_dict
	ModLoaderConfig.update_config(_search_config)

func load_config():
	var default_config = ModLoaderConfig.get_default_config(MOD_NAME)
	_search_config = ModLoaderConfig.get_config(MOD_NAME, CONFIG_NAME)
	if _search_config == null:
		ModLoaderLog.info("no config found, use default", "CharacterSearch")
		_search_config = ModLoaderConfig.create_config(MOD_NAME, CONFIG_NAME, _search_config.data)
		ModLoaderConfig.set_current_config(_search_config)
	else:
		ModLoaderLog.info("config found", "CharacterSearch")
		if merge_with_default_config(_search_config, default_config):
			var _error_config = ModLoaderConfig.update_config(_search_config)	
		ModLoaderConfig.set_current_config(_search_config)
			
	for key in _search_config.data.keys():
		_search_config_dict[key] = _search_config.data[key]

func merge_with_default_config(config:ModConfig, default_config:ModConfig)->bool:
	var update = false
	for key in default_config.data.keys():
		if not config.data.has(key):
			update = true
			config.data[key] = default_config.data[key]
	return update

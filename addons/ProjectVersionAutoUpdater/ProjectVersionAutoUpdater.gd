@tool
extends EditorPlugin

# Constants
var PLUGIN_SETTING_GITVERSION_PATH = "project_version_auto_updater/git_version_path"
var PLUGIN_SETTING_USE_GITVERSION = "project_version_auto_updater/use_git_version"
var PROJECT_VERSION_PATH = "application/config/version"
var DEFAULT_PATH = "res://GitVersion.json"

var gitversion_file

func _enter_tree() -> void:
	if not ProjectSettings.has_setting(PLUGIN_SETTING_USE_GITVERSION):
		ProjectSettings.set_setting(PLUGIN_SETTING_USE_GITVERSION, false)
	if not ProjectSettings.has_setting(PLUGIN_SETTING_GITVERSION_PATH):
		ProjectSettings.set_setting(PLUGIN_SETTING_GITVERSION_PATH, DEFAULT_PATH)

	# Configure the setting for using gitversion
	var plugin_setting_use_gitversion_info = {
		"name": PLUGIN_SETTING_USE_GITVERSION,
		"type": TYPE_BOOL,
		"hint": PROPERTY_HINT_NONE
	}

	# Configure the setting for gitversion path
	var plugin_setting_gitversion_path_info = {
		"name": PLUGIN_SETTING_GITVERSION_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_NONE
	}

	ProjectSettings.set_initial_value(PLUGIN_SETTING_USE_GITVERSION, false)
	ProjectSettings.set_initial_value(PLUGIN_SETTING_GITVERSION_PATH, DEFAULT_PATH)
	ProjectSettings.add_property_info(plugin_setting_use_gitversion_info)	
	ProjectSettings.add_property_info(plugin_setting_gitversion_path_info)

	ProjectSettings.save()	
	

func _build() -> bool:
	getFile()
	autoUpdate()
	
	return true

func autoUpdate() -> void:
	if ProjectSettings.get_setting(PLUGIN_SETTING_USE_GITVERSION):
		print("Updating version using Git Version")
		var new_version = JSON.parse_string(gitversion_file.get_as_text())["SemVer"]
		# Update version
		ProjectSettings.set_setting(PROJECT_VERSION_PATH, new_version)
		ProjectSettings.save()
		print_rich("[color=GREEN]Saved new version: " + new_version)
	else:
		print_rich("[color=YELLOW]Enable Git Version in project advanced settings, to automatically update version.")

func getFile() -> void:
	var path
	var configured_path = ProjectSettings.get_setting(PLUGIN_SETTING_GITVERSION_PATH)
	# Safeguard agains missing path in project settings. This should never occur, but better safe than sorry
	if configured_path == null:
		print_rich("[color=YELLOW]No GitVersion.json path found in project settings. Using default at " + DEFAULT_PATH)
		print_rich("[color=YELLOW]This should not happen. Try re-enabling the plugin, and verify the configuration in Project Settings.")
		path = DEFAULT_PATH
	else:
		path = configured_path
	
	# Trying to get the file from path
	if FileAccess.file_exists(path):
		gitversion_file = FileAccess.open(path, FileAccess.READ)
		if gitversion_file == null:
			print_rich("[color=RED]Failed to open the file: " + path )
		else:
			print_rich("[color=GREEN]File opened successfully: " + path )
	else:
		print_rich("[color=RED]File does not exist at: " + path )
		print_rich("[color=RED]Make sure Git Version is properly configured,")
		print_rich("[color=RED]and that the path in project settings point to the correct file.")

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	gitversion_file = null

	# Removing project settings config if plugin is disabled
	ProjectSettings.clear(PLUGIN_SETTING_GITVERSION_PATH)
	ProjectSettings.clear(PLUGIN_SETTING_USE_GITVERSION)
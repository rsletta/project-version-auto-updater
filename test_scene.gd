extends Node2D

var project_version_path = "application/config/version"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/VersionLabel.text = ProjectSettings.get_setting(project_version_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

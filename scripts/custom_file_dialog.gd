class_name CustomFileDialog extends FileDialog

signal finished()

var valid := false

func _init(mode: FileMode) -> void:
  file_mode = mode
  access = FileDialog.ACCESS_FILESYSTEM
  dialog_hide_on_ok = true
  always_on_top = true
  size = Vector2i(1280 / 2, 720 / 2)
  position = Vector2i(1280 / 2 - 1280 / 4, 720 / 2 - 720 / 4)
  file_selected.connect(_on_file_selected)
  canceled.connect(_on_canceled)
  
func _on_file_selected(path: String) -> void:
  valid = true
  finished.emit()

func _on_canceled() -> void:
  valid = false
  finished.emit()
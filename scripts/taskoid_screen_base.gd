class_name TaskoidScreenBase extends GridContainer

@onready var exit_button = $ExitButton
@onready var taskoid_name: TextEdit = $Name
@onready var description: TextEdit = $Description
@onready var capacity: TextEdit = $Difficulty
@onready var parent: TextEdit = $Parent
@onready var complete_button: Button = $CompleteButton
@onready var has_deadline: CheckButton = $HasDeadline
@onready var deadline: DateControl = $Deadline

var _taskoid: Taskoid = null
var _repetition_config := RepetitionConfigDialogItems.new()

func set_taskoid(taskoid: Taskoid):
  _taskoid = taskoid
  taskoid_name.text = taskoid.name
  description.text = taskoid.description
  capacity.text = Difficulty.difficulty_names[taskoid.difficulty]
  parent.text = taskoid.parent.name if taskoid.parent else ""
  has_deadline.button_pressed = taskoid.has_deadline
  deadline.date = taskoid.deadline.to_dict() if taskoid.has_deadline else {}
  if taskoid.repetition_config:
    _repetition_config.toggle(false)
    _repetition_config.set_config(taskoid.repetition_config)
    _repetition_config.add_nodes_as_siblings_to(deadline)
  complete_button.disabled = taskoid.completed
    
func _on_exit_button_pressed() -> void:
  hide()

func _on_complete_button_pressed() -> void:
  var result := _taskoid.complete()
  if not result.result:
    Globals.show_error_screen("Taskoid couldn't be completed: " + str(result.error))
    return
  complete_button.disabled = true

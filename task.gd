class_name Task extends RefCounted

# The assigned values have days as unit
enum TaskDifficulty {
	Easy = 1,
	Medium = 10,
	Hard = 20,
	Gigantic
}

signal done

var name: String = ""
var completed: bool = false
var parent: Task = null
## Tells if the parent can be completed without completing this task.
var optional: bool = true
var children: Array[Task]
var combined_difficulty: TaskDifficulty = TaskDifficulty.Easy
var own_difficulty: TaskDifficulty = TaskDifficulty.Easy
var children_difficulty: int = 0

func _init(name: String, parent: Task, optional: bool, difficulty: TaskDifficulty) -> void:
	self.name = name
	self.parent = parent
	self.optional = optional
	own_difficulty = difficulty
	combined_difficulty = difficulty

func add_child(child: Task) -> void:
	children.append(child)
	match children_difficulty + child.combined_difficulty:
		var new_diff when new_diff > TaskDifficulty.Hard:
			combined_difficulty = TaskDifficulty.Gigantic
		var new_diff when new_diff > TaskDifficulty.Medium:
			combined_difficulty = TaskDifficulty.Hard
		var new_diff when new_diff > TaskDifficulty.Easy:
			combined_difficulty = TaskDifficulty.Medium
	children_difficulty += child.combined_difficulty
	
func remove_child(child: Task) -> void:
	children.erase(child)

func complete() -> bool:
	for child in children:
		if not child.completed and not child.optional:
			return false
	completed = true
	done.emit()
	return true

func on_child_done(child) -> void:
	pass

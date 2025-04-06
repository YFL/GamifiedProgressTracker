class_name RepetitionConfigDialogItems extends RefCounted

var starting_date_label := Label.new()
var starting_date := DateControl.new()
var interval_label := Label.new()
var interval := IntervalControl.new()

func _init() -> void:
  starting_date_label.text = "Starting date"
  interval_label.text = "Interval"

func _notification(what: int) -> void:
  if what == NOTIFICATION_PREDELETE:
    if is_instance_valid(starting_date_label):
      starting_date_label.queue_free()
    if is_instance_valid(starting_date):
      starting_date.queue_free()
    if is_instance_valid(interval_label):
      interval_label.queue_free()
    if is_instance_valid(interval):
      interval.queue_free()

func set_config(config: RepetitionConfig) -> void:
  starting_date.date = config.starting_date.to_dict()
  interval.date = config.interval.to_dict()

func toggle(enabled: bool) -> void:
  starting_date.toggle(enabled)
  interval.toggle(enabled)

func add_nodes_as_siblings_to(node: Node) -> void:
  node.add_sibling(starting_date_label)
  starting_date_label.add_sibling(starting_date)
  starting_date.add_sibling(interval_label)
  interval_label.add_sibling(interval)

func remove_children_from_parent() -> void:
  var parent: Node = starting_date_label.get_parent()
  if parent:
    parent.remove_child(starting_date_label)
  parent = starting_date.get_parent()
  if parent:
    parent.remove_child(starting_date)
  parent = interval_label.get_parent()
  if parent:
    parent.remove_child(interval_label)
  parent = interval.get_parent()
  if parent:
    parent.remove_child(interval)

func reset() -> void:
  starting_date.reset()
  interval.reset()
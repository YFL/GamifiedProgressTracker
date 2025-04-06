class_name GameWorldSize extends RefCounted

var x := 0
var y := 0
var remainder := 0

func _init(difficulty: int):
  difficulty = difficulty / Difficulty.Modest
  var square := int(sqrt(difficulty))
  var best_difficulty_diff := difficulty - square * square
  var best_dimension_diff := square - (difficulty - square)
  if best_dimension_diff < 0:
    best_dimension_diff *= -1
  for width in range(square, difficulty + 1):
    var height := difficulty / width
    var diff := difficulty - width * height
    var dimension_diff := width - height
    if dimension_diff < 0:
      dimension_diff *= -1
    if diff <= best_difficulty_diff and dimension_diff <= best_dimension_diff:
      x = width
      y = height
      best_difficulty_diff = diff
    if diff == 0:
      break
  if x < y:
    var tmp := x;
    x = y
    y = tmp
  if difficulty != x * y:
    remainder = difficulty - x * y
  x *= 3
  y *= 2
  remainder *= 3

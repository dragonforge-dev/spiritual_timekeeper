extends SpinBox


signal start_timer


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("start_timer"):
		start_timer.emit()

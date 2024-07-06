extends CanvasLayer

var _running: bool = false
var _change_share_minute: int = false
var _spinner_node: SpinBox = null


# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.text = "Start"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _running:
		#check if the timer has decremented and update the display
		$CountdownDisplay.text = _format_time($ShareOverTimer.time_left)
	if _change_share_minute != 0:
		_spinner_node.value += _change_share_minute
		_change_share_minute = false
		_spinner_node = null


func start_timer():
	var seconds = _get_share_time_start()
	#Reset Time display
	$CountdownDisplay.text = _format_time(seconds)
	#Start Timer
	$ShareOverTimer.wait_time = seconds + 1
	$ShareOverTimer.start()
	#Start Warning Timer
	$WarningTimer.wait_time = seconds - _get_warning_time_start()
	$WarningTimer.start()
	#Hide warning Label
	$LabelContainer.hide()
	_change_label_colors(Color.GOLD)
	$LabelContainer/WarningLabel.text = "Warning"
	var message = 'Say: "' + _format_time_as_string(_get_warning_time_start()) + '"'
	$LabelContainer/Message.text = message
	_running = true


func _format_time(seconds):
	var sec: int = seconds
	var minutes: int = seconds/60
	sec %= 60
	seconds = str(sec)
	if sec < 10: seconds = "0" + seconds
	var text = str(minutes) + " : " + seconds
	return text


func _format_time_as_string(seconds):
	var sec: int = seconds
	var minutes: int = seconds/60
	sec %= 60
	seconds = str(sec)
	if minutes == 0:
		return seconds + " Seconds"
	elif sec == 0:
		var text = str(minutes) + " Minute"
		if minutes > 1: text += "s"
		return text
	else:
		var text = str(minutes) + " Minute"
		if minutes > 1: text += "s"
		text += " " + seconds + " Seconds"
		return text


func _convert_to_seconds(minutes, seconds):
	return ((minutes * 60) + seconds)


func _get_share_time_start():
	return _convert_to_seconds($ShareTimeContainer/ShareTimeMin.value, $ShareTimeContainer/ShareTimeSec.value)


func _get_warning_time_start():
	return _convert_to_seconds($WarningTimeContainer/WarningTimeMin.value, $WarningTimeContainer/WarningTimeSec.value)


func _on_start_button_pressed():
	if $StartButton.text == "Start":
		$StartButton.text = "Restart"
	start_timer()


func _on_warning_timer_timeout():
	$LabelContainer.show()


func _on_share_over_timer_timeout():
	_running = false
	_change_label_colors(Color.RED)
	$LabelContainer/WarningLabel.text = "Time's Up!"
	$LabelContainer/Message.text = 'Say: "Time"'
	$StartButton.text = "Start"


func _on_share_time_sec_value_changed(value):
	var minute = $ShareTimeContainer/ShareTimeMin
	var second = $ShareTimeContainer/ShareTimeSec
	change_time(minute, second, value)


func _on_warning_time_sec_value_changed(value):
	var minute = $WarningTimeContainer/WarningTimeMin
	var second = $WarningTimeContainer/WarningTimeSec
	change_time(minute, second, value)


func change_time(minute, second, value):
	if value == 60:
		second.value = 0
		_change_share_minute = 1
		_spinner_node = minute
	elif value == -15:
		if minute.value == 0:
			second.value = 0
		else:	
			second.value = 45
			_change_share_minute = -1
			_spinner_node = minute


func _change_label_colors(color):
	$LabelContainer/WarningLabel.add_theme_color_override("font_color", color)
	$LabelContainer/Message.add_theme_color_override("font_color", color)


func _on_info_button_pressed():
	$PopupPanel.popup()


func _on_rich_text_label_meta_clicked(meta):
	OS.shell_open(str(meta))


func _on_license_button_pressed():
	$PopupPanel/License.popup()


func _on_second_lock_toggled(toggled_on):
	if toggled_on:
		$ShareTimeContainer/ShareTimeSec.step = 1

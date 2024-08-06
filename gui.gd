extends CanvasLayer

@onready var countdown_display: Label = $CountdownDisplay
@onready var share_time_minutes: SpinBox = $ShareTimeContainer/ShareTimeMin
@onready var share_time_seconds: SpinBox = $ShareTimeContainer/ShareTimeSec
@onready var warning_time_minutes: SpinBox = $WarningTimeContainer/WarningTimeMin
@onready var warning_time_seconds: SpinBox = $WarningTimeContainer/WarningTimeSec
@onready var message_container: Container = $LabelContainer
@onready var message_header: Label = $LabelContainer/WarningLabel
@onready var message_body: Label = $LabelContainer/Message
@onready var start_button: Button = $StartButtonContainer/StartButton
@onready var start_button_tooltip: Label = $StartButtonContainer/TooltipLabel
@onready var version_label: Label = $VersionLabel

@onready var info_window: PopupPanel = $PopupPanel
@onready var license_info_window: PopupPanel = $PopupPanel/License


@onready var timer_share_over: Timer = $ShareOverTimer
@onready var timer_warning: Timer = $WarningTimer

var _running: bool = false
var _change_share_minute: int = false
var _spinner_node: SpinBox = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.text = "Start"
	version_label.text = get_version()
	share_time_minutes.start_timer.connect(_on_start_timer_signal_sent)
	share_time_seconds.start_timer.connect(_on_start_timer_signal_sent)
	warning_time_minutes.start_timer.connect(_on_start_timer_signal_sent)
	warning_time_seconds.start_timer.connect(_on_start_timer_signal_sent)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	if _running:
		#check if the timer has decremented and update the display
		countdown_display.text = _format_time(timer_share_over.time_left)
	if _change_share_minute != 0:
		_spinner_node.value += _change_share_minute
		_change_share_minute = false
		_spinner_node = null


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start_timer"):
		start_timer()


func start_timer() -> void:
	var seconds = _get_share_time_start()
	#Reset Time display
	countdown_display.text = _format_time(seconds)
	#Start Timer
	timer_share_over.wait_time = seconds + 1
	timer_share_over.start()
	#Start Warning Timer
	timer_warning.wait_time = seconds - _get_warning_time_start()
	timer_warning.start()
	#Hide warning Label
	message_container.hide()
	_change_label_colors(Color.GOLD)
	message_header.text = "Warning"
	var message = 'Say: "' + _format_time_as_string(_get_warning_time_start()) + '"'
	message_body.text = message
	_running = true


func _format_time(seconds) -> String:
	var sec: int = seconds
	var minutes: int = seconds/60
	sec %= 60
	seconds = str(sec)
	if sec < 10: seconds = "0" + seconds
	var text = str(minutes) + " : " + seconds
	return text


func _format_time_as_string(seconds) -> String:
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


func _convert_to_seconds(minutes, seconds) -> int:
	return ((minutes * 60) + seconds)


func _get_share_time_start() -> int:
	return _convert_to_seconds(share_time_minutes.value, share_time_seconds.value)


func _get_warning_time_start() -> int:
	return _convert_to_seconds(warning_time_minutes.value, warning_time_seconds.value)


func _on_start_button_pressed() -> void:
	if start_button.text == "Start":
		start_button.text = "Restart"
	start_timer()


func _on_warning_timer_timeout() -> void:
	message_container.show()


func _on_share_over_timer_timeout() -> void:
	_running = false
	_change_label_colors(Color.RED)
	message_header.text = "Time's Up!"
	message_body.text = 'Say: "Time"'
	start_button.text = "Start"


func _on_share_time_sec_value_changed(value) -> void:
	var minute = share_time_minutes
	var second = share_time_seconds
	change_time(minute, second, value)


func _on_warning_time_sec_value_changed(value) -> void:
	var minute = warning_time_minutes
	var second = warning_time_seconds
	change_time(minute, second, value)


func change_time(minute, second, value) -> void:
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


func _change_label_colors(color) -> void:
	message_header.add_theme_color_override("font_color", color)
	message_body.add_theme_color_override("font_color", color)


func _on_info_button_pressed() -> void:
	info_window.popup()


func _on_rich_text_label_meta_clicked(meta) -> void:
	OS.shell_open(str(meta))


func _on_license_button_pressed() -> void:
	license_info_window.popup()


func _on_start_button_mouse_entered() -> void:
	start_button_tooltip.visible = true


func _on_start_button_mouse_exited() -> void:
	start_button_tooltip.visible = false


func _on_start_timer_signal_sent() -> void:
	start_button.grab_focus()
	start_timer()


func get_version() -> String:
	var project_version = ProjectSettings.get_setting("application/config/version")
	var version_file_path = "res://version.txt"
	var saved_version = FileAccess.open(version_file_path, FileAccess.READ).get_as_text()
	
	if project_version == "":
		project_version = "v%s" % saved_version
	elif project_version != saved_version:
		FileAccess.open(version_file_path, FileAccess.WRITE).store_string(project_version)
	
	return project_version

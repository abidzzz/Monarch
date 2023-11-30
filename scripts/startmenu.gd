extends Control

@onready var setting_menu = $SettingsMenu
@onready var video_settings = $SettingsMenu/MainMenu2/SettingsContainer/VideoSettings
@onready var audio_settings = $SettingsMenu/MainMenu2/SettingsContainer/AudioSettings
@onready var control_settings = $SettingsMenu/MainMenu2/SettingsContainer/ControlsSettings
@onready var animation_player = $AnimationPlayer
@onready var start_btn = $MainMenu/StartBtn
@onready var main_menu = $MainMenu

func _ready():
	start_btn.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Audio/bgm.play()
	
func _on_StartBtn_pressed():
	$Audio/enter.play()
	start_btn.release_focus()
	animation_player.play("fade")	
	await get_tree().create_timer(1).timeout
	
	$Controls.show()
	animation_player.play("Fade_Controls")
	await get_tree().create_timer(2.5).timeout

	get_tree().change_scene_to_file("res://scenes/lobby.tscn")


func _on_SettingsBtn_pressed():
	$Audio/enter.play()
	setting_menu.popup_centered()
	hide_settings()
	video_settings.show()


func _on_QuitBtn_pressed():
	$Audio/enter.play()
	get_tree().quit()


func _on_VideoBtn_pressed():
	hide_settings()
	video_settings.show()


func _on_AudioBtn_pressed():
	hide_settings()
	audio_settings.show()


func _on_ControlsBtn_pressed():
	hide_settings()
	control_settings.show()
	
	
func hide_settings():
	video_settings.hide()
	audio_settings.hide()
	control_settings.hide()
	play_animation()


func play_animation():
	animation_player.play("settings")




func _on_start_btn_focus_entered():
	$Audio/select.play()

func _on_start_btn_mouse_entered():
	$Audio/select.play()


func _on_settings_btn_focus_entered():
	$Audio/select.play()


func _on_settings_btn_mouse_entered():
	$Audio/select.play()


func _on_quit_btn_focus_entered():
	$Audio/select.play()


func _on_quit_btn_mouse_entered():
	$Audio/select.play()

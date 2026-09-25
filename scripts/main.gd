extends Node2D

@onready var score_label: Label = $HUD/ScoreLabel
@onready var timer: Timer = $Timer
@onready var time_label: Label = $HUD/TimeLabel
@onready var game_over_panel: PanelContainer = $HUD/GameOverPanel
@onready var game_over_audio: AudioStreamPlayer = $GameOverAudio
@onready var high_score_label: Label = $HUD/HighScoreLabel
@onready var player: CharacterBody2D = $Player
@onready var crack_effect: Sprite2D = $CrackEffect
@onready var start_audio: AudioStreamPlayer = $StartAudio

@onready var watch_ad_button: Button = $HUD/GameOverPanel/VBoxContainer/AdButton
@onready var remove_ads_button: Button = $HUD/GameOverPanel/VBoxContainer/NoAdsButton

@export var orb_scene: PackedScene

var score: int = 0
var high_score: int = 0

func _process(_delta: float) -> void:
	time_label.text = "Tiempo: " + str(int(timer.time_left))

func update_score_display() -> void:
	score_label.text = "Puntos: " + str(score)
	
func update_high_score_display() -> void:
	high_score_label.text = "Récord: " + str(high_score)

func _ready() -> void:
	start_audio.play()
	var viewport_center = get_viewport_rect().size / 2
	player.position = viewport_center
	
	load_high_score()
	update_high_score_display()
	
	spawn_orb()
	update_score_display()
	
	if InAppManager.has_removed_ads:
		remove_ads_button.hide()
	
func spawn_orb() -> void:
	var orb = orb_scene.instantiate()
	
	var screen_size = get_viewport_rect().size
	
	var margin_x = 60.0
	var margin_top = 100.0
	var margin_bottom = 60.0
	
	var random_x = randf_range(margin_x, screen_size.x - margin_x)
	var random_y = randf_range(margin_top, screen_size.y - margin_bottom)
	
	orb.position = Vector2(random_x, random_y)
	orb.collected.connect(_on_orb_collected)
	
	call_deferred("add_child", orb)
	
func _on_orb_collected() -> void:
	score += 1
	update_score_display()
	spawn_orb()


func _on_timer_timeout() -> void:
	time_label.text = "Tiempo: 0"
	
	if score > high_score:
		high_score = score
		save_high_score()
		update_high_score_display()
	
	crack_effect.position = get_viewport_rect().size / 2
	crack_effect.show()
	
	game_over_audio.play()
	game_over_panel.show()
	get_tree().paused = true
	
	if not InAppManager.has_removed_ads:
		AdManager.show_interstitial()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
	
func _on_watch_ad_button_pressed() -> void:
	AdManager.reward_granted_connect(_on_reward_earned, CONNECT_ONE_SHOT)
	AdManager.show_rewarded()
	
func _on_reward_earned() -> void:
	get_tree().paused = false
	game_over_panel.hide()
	crack_effect.hide()
	
	timer.start(10.0)
	watch_ad_button.hide()
	
func _on_remove_ads_button_pressed() -> void:
	InAppManager.purchase_successful.connect(_on_purchase_completed, CONNECT_ONE_SHOT)
	InAppManager.purchase_remove_ads()
	
func _on_purchase_completed(product_id: String) -> void:
	if product_id == "remove_ads":
		remove_ads_button.hide()

func save_high_score() -> void:
	var config = ConfigFile.new()
	config.set_value("game", "high_score", high_score)
	config.save("user://highscore.cfg")
	
func load_high_score() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://highscore.cfg")
	if err == OK:
		high_score = config.get_value("game", "high_score", 0)

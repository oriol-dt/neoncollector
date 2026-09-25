extends Node

signal interstitial_closed
signal reward_granted

var is_admob_available: bool = false
var _interstitial_ad = null
var _rewarded_ad = null

const INTERSTITIAL_ID_TEST: String = "ca-app-pub-3940256099942544/1033173712"
const REWARDED_ID_TEST: String = "ca-app-pub-3940256099942544/5224354917"

func _ready() -> void:
	if OS.get_name() == "Android" and Engine.has_singleton("PoingGodotAdMob"):
		is_admob_available = true
		
		# Inicialización del SDK
		if ClassDB.class_exists("MobileAds"):
			MobileAds.initialize()
		
		print("[AdManager] Inicializando AdMob en Android...")
		load_interstitial()
		load_rewarded()
	else:
		print("[AdManager] Modo simulación activo (PC/Editor).")

# --- INTERSTITIAL ---

func load_interstitial() -> void:
	if not is_admob_available:
		return
	
	# Usamos el cargador oficial del addon mediante la factoría de clases o instanciación directa
	if ClassDB.class_exists("InterstitialAdLoader"):
		var loader = InterstitialAdLoader.new()
		var ad_request = AdRequest.new()
		
		# Conectamos mediante callable seguro a la señal de carga completada
		if not loader.is_connected("on_interstitial_ad_loaded", _on_interstitial_loaded):
			loader.on_interstitial_ad_loaded.connect(_on_interstitial_loaded)
		if not loader.is_connected("on_interstitial_ad_failed_to_load", _on_interstitial_failed_to_load):
			loader.on_interstitial_ad_failed_to_load.connect(_on_interstitial_failed_to_load)
			
		loader.load(INTERSTITIAL_ID_TEST, ad_request)

func _on_interstitial_loaded(interstitial_ad) -> void:
	_interstitial_ad = interstitial_ad
	print("[AdManager] ¡Anuncio Interstitial cargado con éxito en memoria!")
	
	if _interstitial_ad:
		if not _interstitial_ad.is_connected("on_ad_dismissed_full_screen_content", _on_interstitial_dismissed):
			_interstitial_ad.on_ad_dismissed_full_screen_content.connect(_on_interstitial_dismissed)

func _on_interstitial_failed_to_load(error) -> void:
	print("[AdManager] Fallo al cargar el Interstitial de AdMob. Código de error: ", error)

func show_interstitial() -> void:
	if is_admob_available and _interstitial_ad:
		print("[AdManager] Mostrando Interstitial...")
		_interstitial_ad.show()
	else:
		print("[AdManager Simulación / No listo] Anuncio Interstitial simulado.")
		interstitial_closed.emit()

func _on_interstitial_dismissed() -> void:
	print("[AdManager] Interstitial cerrado por el usuario.")
	_interstitial_ad = null
	interstitial_closed.emit()
	load_interstitial() # Precargar el siguiente

# --- REWARDED ---

func load_rewarded() -> void:
	if not is_admob_available:
		return
		
	if ClassDB.class_exists("RewardedAdLoader"):
		var loader = RewardedAdLoader.new()
		var ad_request = AdRequest.new()
		
		if not loader.is_connected("on_rewarded_ad_loaded", _on_rewarded_loaded):
			loader.is_connected("on_rewarded_ad_loaded", _on_rewarded_loaded) # por si acaso
			loader.on_rewarded_ad_loaded.connect(_on_rewarded_loaded)
			
		loader.load(REWARDED_ID_TEST, ad_request)

func _on_rewarded_loaded(rewarded_ad) -> void:
	_rewarded_ad = rewarded_ad
	print("[AdManager] ¡Anuncio Rewarded cargado con éxito!")

func show_rewarded() -> void:
	if is_admob_available and _rewarded_ad:
		var listener = OnUserEarnedRewardListener.new()
		listener.on_user_earned_reward = _on_user_earned_reward
		_rewarded_ad.show(listener)
	else:
		print("[AdManager Simulación] Anuncio Bonificado completado. Recompensa otorgada.")
		reward_granted.emit()

func _on_user_earned_reward(_reward) -> void:
	print("[AdManager] ¡Recompensa obtenida!")
	_rewarded_ad = null
	reward_granted.emit()
	load_rewarded()

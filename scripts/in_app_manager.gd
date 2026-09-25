extends Node

signal purchase_successful(product_id: String)
signal purchase_failed

var payment_plugin: Object = null
var has_removed_ads: bool = false

func _ready() -> void:
	if Engine.has_singleton("GodotGooglePlayBilling"):
		payment_plugin = Engine.get_singleton("GodotGooglePlayBilling")

func purchase_remove_ads() -> void:
	if payment_plugin:
		payment_plugin.purchase("remove_ads")
	else:
		print("[InAppManager Simulación] Compra 'remove_ads' realizada con éxito.")
		has_removed_ads = true
		purchase_successful.emit("remove_ads")

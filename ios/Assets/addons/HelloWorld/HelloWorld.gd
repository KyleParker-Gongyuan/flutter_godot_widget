

@tool
extends EditorPlugin


var exportPlugin : AndroidExportPlugin

func _enter_tree():
	print("preplugin")
	# Initialization of the plugin goes here.
	exportPlugin = AndroidExportPlugin.new()
	add_export_plugin(exportPlugin)

	print("added plug")
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_export_plugin(exportPlugin)
	exportPlugin = null
	pass


class AndroidExportPlugin extends EditorExportPlugin:
	var pluginName = "godotP"
	func _supports_platform(platform):
		if platform is EditorExportPlatformAndroid:
			print("we got the export")
			return true
		return false
		
	func _get_android_libraries(platform, debug):
		if debug:
			print("is debug yo")
			return PackedStringArray(["flutter_release-1.0.aar"])
		else: 
			return PackedStringArray(["flutter_release-1.0.aar"])
	func _get_android_dependencies(platform, debug):
			
		if debug: # might need flutter dependancies????
			return PackedStringArray([])
		else:
			return PackedStringArray([])
			
			
	func _get_name():
		return pluginName
	


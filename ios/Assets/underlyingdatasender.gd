extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#if Engine.has_singleton("ad"):
	#	print("MOMS A HOE")
	
'''
	
	
	#Adds a user-defined signal.
	# Optional arguments for the signal can be added as an Array of dictionaries,
	# each defining a name String and a type int (see Variant.Type). See also has_user_signal().
	
	add_user_signal("datasending", [
		{ "name": "generic", "type": TYPE_STRING },
		{ "name": "database", "type": TYPE_STRING },
		{ "name": "exit", "type": TYPE_STRING }
		
	])
	Engine.register_singleton("name",Object) # idk what exactly the object is tbh
	
	Engine.emit_signal("genericData", "sword", 100)
	pass # Replace with function body.
'''

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

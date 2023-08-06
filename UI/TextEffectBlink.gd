tool
extends RichTextEffect
class_name RichTextEffectBlink

# Syntax: [blink freq=1][/blink]

# Define the tag name.
var bbcode = "blink"

func _process_custom_fx(char_fx):
	# Get parameters, or use the provided default value if missing.
	var freq = char_fx.env.get("freq", 1.5)

	char_fx.color.a = round(abs(sin(char_fx.elapsed_time * freq)))
	return true

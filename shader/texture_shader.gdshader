shader_type canvas_item;

uniform sampler2D TEXT : filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 screenColor = texture(TEXT,UV);
	COLOR = screenColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

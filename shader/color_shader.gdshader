shader_type canvas_item;

uniform vec3 COL;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 screenColor = vec4(COL,1.0);
	COLOR = screenColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

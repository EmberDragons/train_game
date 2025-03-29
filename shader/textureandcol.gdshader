shader_type canvas_item;

uniform vec4 COL;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 screenColor = vec4(COL.xyz,0.6)*texture(TEXTURE,UV);
	COLOR = screenColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

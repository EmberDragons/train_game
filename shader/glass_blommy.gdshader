shader_type canvas_item;

uniform sampler2D TEXT : hint_screen_texture;
uniform sampler2D NEW_TEXTURE : filter_nearest;
uniform sampler2D dirstortionTexture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 distortedUV = SCREEN_UV + texture(dirstortionTexture,UV*(1.0+cos(TIME)*0.2+sin(TIME-0.3)*0.04)).r*0.004;
	vec4 screenColor = texture(NEW_TEXTURE,UV);
	screenColor*=0.5;
	screenColor += texture(TEXT,distortedUV);
	COLOR = screenColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

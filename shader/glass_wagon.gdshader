shader_type canvas_item;

uniform sampler2D dirstortionTexture;
uniform float multiplyier;

void fragment() {
	vec2 distortedUV = (multiplyier/10.0)*SCREEN_UV*0.01*cos(sin(TIME*0.01+2.9)*0.2)*0.6 + texture(dirstortionTexture,UV).r*0.05*cos(sin(multiplyier*TIME*0.05+2.9)*1.2)*1.6;
	vec4 screenColor = texture(TEXTURE,distortedUV);
	COLOR = screenColor;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

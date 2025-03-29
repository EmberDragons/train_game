shader_type canvas_item;


uniform vec4 color_tint : source_color;
uniform sampler2D noise : repeat_enable;
uniform float intensity;
uniform vec2 scale;
uniform vec2 scale_distortion;
uniform float speed;

uniform sampler2D r_SCREEN_TEXTURE : hint_screen_texture;
uniform float top_strength;
void fragment() {
	float distortion = texture(noise, UV*scale*scale_distortion + TIME*speed).x;
	distortion -= 0.5;

	
	float top_uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 top_screen_uv = vec2(SCREEN_UV.x-distortion*intensity, SCREEN_UV.y - top_uv_height * scale.y * 2.0);
	
	float distortion_top = top_strength*pow((texture(noise, (UV*top_screen_uv*scale*scale_distortion + TIME*speed)).x),2.0)*2.0;
	vec4 top_layer = color_tint*distortion_top;
	COLOR.rgb = mix(vec3(0,0,0), texture(r_SCREEN_TEXTURE, SCREEN_UV).rgb,0.4);
	if (distortion_top>=0.1){
		COLOR.rgb += top_layer.rgb*0.2;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}

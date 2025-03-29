shader_type canvas_item;

uniform vec4 color_tint : source_color;
uniform vec4 color_top : source_color;
uniform float top_strength;
uniform sampler2D noise : repeat_enable;
uniform sampler2D noise_top : repeat_enable;
uniform float intensity;
uniform vec2 scale_distortion;
uniform float speed;

uniform vec2 scale;
uniform float y_zoom;

uniform sampler2D SCREEN_TEXTURE;
uniform sampler2D r_SCREEN_TEXTURE : hint_screen_texture;

void fragment() {
	float distortion = texture(noise, UV*scale*scale_distortion + TIME*speed).x;
	distortion -= 0.5;

	float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	float top_uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
	vec2 reflected_screen_uv = vec2(SCREEN_UV.x-distortion*intensity, SCREEN_UV.y - uv_height * UV.y * scale.y * y_zoom * 2.0);
	vec2 top_screen_uv = vec2(SCREEN_UV.x-distortion*intensity, SCREEN_UV.y - top_uv_height * scale.y * y_zoom * 2.0);
	
	vec4 reflection = texture(r_SCREEN_TEXTURE, reflected_screen_uv);
	if (reflected_screen_uv.y<=TEXTURE_PIXEL_SIZE.y){
		reflection = texture(r_SCREEN_TEXTURE, vec2(reflected_screen_uv.x, -reflected_screen_uv.y));
	}
	
	float distortion_top = top_strength*pow((texture(noise, (UV*top_screen_uv*scale*scale_distortion + TIME*speed)).x),2.0)*2.0;
	vec4 top_layer = color_top*distortion_top;
	if (texture(r_SCREEN_TEXTURE, SCREEN_UV).b >0.8){
		COLOR.rgb = mix(reflection.rgb, color_tint.rgb, color_tint.a);
		if (distortion_top>=0.1){
			COLOR.rgb += top_layer.rgb*0.2;
		}
	}
	else{
		COLOR = texture(r_SCREEN_TEXTURE, SCREEN_UV);
	}
}

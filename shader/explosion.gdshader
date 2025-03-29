shader_type canvas_item;

uniform vec2 center;
uniform float force;
uniform float size;
uniform float thickness;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;
	vec2 scaled_uv = ( SCREEN_UV-vec2(0.5,0.0))/vec2(ratio,1.0)+vec2(0.5,0.0);
	float mask = (1.0-smoothstep(size-0.1, size,length(scaled_uv-center)))
			* smoothstep(size-thickness, size-thickness,length(scaled_uv-center));
	vec2 disp = normalize(SCREEN_UV - center)*force*mask;
	//COLOR = vec4(SCREEN_UV - disp,0,1);
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
}

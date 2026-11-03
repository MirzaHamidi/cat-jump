shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float scanline_strength : hint_range(0.0, 0.4) = 0.22;
uniform float vignette_strength : hint_range(0.0, 0.3) = 0.10;

void fragment() {
    vec3 base = texture(screen_texture, SCREEN_UV).rgb;
    float scanline = 0.5 + 0.5 * cos((FRAGCOORD.y - 0.5) * 1.5707963);
    vec2 from_center = (SCREEN_UV - vec2(0.5)) * vec2(1.0, 0.75);
    float edge = smoothstep(0.22, 0.65, length(from_center));
    COLOR = vec4(base * (1.0 - scanline_strength * scanline) * (1.0 - vignette_strength * edge), 1.0);
}

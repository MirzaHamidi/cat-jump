shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float scanline_strength : hint_range(0.0, 0.4) = 0.22;
uniform float vignette_strength : hint_range(0.0, 0.3) = 0.10;
uniform float curvature : hint_range(0.0, 0.15) = 0.04;

void fragment() {
    vec2 centered = SCREEN_UV * 2.0 - 1.0;
    // Keep UVs inside the source image while gently curving straight edges.
    vec2 warped_uv = 0.5 + 0.5 * centered * (1.0 + curvature * dot(centered, centered)) / (1.0 + 2.0 * curvature);
    vec3 base = texture(screen_texture, warped_uv).rgb;
    float scanline = 0.5 + 0.5 * cos((FRAGCOORD.y - 0.5) * 1.5707963);
    vec2 from_center = (SCREEN_UV - vec2(0.5)) * vec2(1.0, 0.75);
    float edge = smoothstep(0.22, 0.65, length(from_center));
    COLOR = vec4(base * (1.0 - scanline_strength * scanline) * (1.0 - vignette_strength * edge), 1.0);
}

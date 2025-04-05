shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (SCREEN_UV.x > 0.63) {
        tex_color.a = 0.0;
    }
    COLOR = tex_color;
}

shader_type canvas_item;
void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    vec3 c = tex.rgb;
    // Marrón oscuro → verde oscuro
    if (distance(c, vec3(124.0, 8.0, 0.0) / 255.0) < 0.03) {
        c = vec3(0.0, 79.0, 0.0) / 255.0;
    }
    // Naranja → verde
    if (distance(c, vec3(200.0, 76.0, 12.0) / 255.0) < 0.03) {
        c = vec3(0.0, 168.0, 0.0) / 255.0;
    }
    COLOR = vec4(c, tex.a);
}

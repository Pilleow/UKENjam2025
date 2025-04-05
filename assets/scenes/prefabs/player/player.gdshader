shader_type canvas_item;

// Uniform to control hue shift (in radians)
uniform float hue_shift : hint_range(-3.1416, 3.1416) = 0.0;

// Matrices to convert between RGB and YIQ color spaces
const mat3 rgb2yiq = mat9(
    0.299,    0.587,    0.114,
    0.595716, -0.274453, -0.321263,
    0.211456, -0.522591,  0.311135
);

const mat3 yiq2rgb = mat3(
    1.0,  0.9563,  0.6210,
    1.0, -0.2721, -0.6474,
    1.0, -1.1070,  1.7046
);

void fragment() {
    // Sample the texture color
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Convert RGB to YIQ
    vec3 yiq = rgb2yiq * tex_color.rgb;
    
    // Calculate current hue and chroma
    float hue = atan(yiq.z, yiq.y);
    float chroma = sqrt(yiq.y * yiq.y + yiq.z * yiq.z);
    
    // Adjust hue by the specified hue_shift
    hue += hue_shift;
    
    // Convert back to YIQ components with the new hue
    yiq.y = chroma * cos(hue);
    yiq.z = chroma * sin(hue);
    
    // Convert YIQ back to RGB
    vec3 new_rgb = yiq2rgb * yiq;
    
    // Output the final color with the original alpha
    COLOR = vec4(new_rgb, tex_color.a);
}

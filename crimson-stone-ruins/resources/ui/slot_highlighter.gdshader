shader_type spatial;

uniform float flash_speed : hint_range(0.1, 10.0) = 2.0;
uniform vec3 purple_color : source_color = vec3(0.5, 0.0, 0.5);
uniform float min_brightness : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    float flash = sin(TIME * flash_speed) * 0.5 + 0.5;
    flash = mix(min_brightness, 1.0, flash);
    ALBEDO = purple_color * flash;
    EMISSION = purple_color * flash * 0.5;
}
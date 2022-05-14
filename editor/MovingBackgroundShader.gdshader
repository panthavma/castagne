shader_type canvas_item;

uniform vec4 colorA : hint_color = vec4(0.11,0.15,0.12,1);
uniform vec4 colorB : hint_color = vec4(0.11,0.22,0.12,1);
const vec2 lineSize = vec2(30.0,30.0);
const float speed = 0.4;

void fragment() {
	float t = step(0, sin(SCREEN_UV.x*lineSize.x + SCREEN_UV.y*-lineSize.y + TIME*-speed));
	COLOR = mix(colorA, colorB, t);
}